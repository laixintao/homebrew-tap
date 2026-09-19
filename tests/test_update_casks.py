"""Check update ordering, release channels, and installer integrity without network access."""

import hashlib
import importlib.util
import json
from pathlib import Path
import re
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parent.parent
SPEC = importlib.util.spec_from_file_location("update_casks", ROOT / "scripts/update_casks.py")
UPDATER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(UPDATER)


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.folder = Path(self.temporary.name)
        self.packages = json.loads((ROOT / "packages.json").read_text())

    def fixture(self, token, version="9.0.0"):
        package = self.packages[token]
        cask = self.folder / f"{token}.rb"
        cask.write_text(re.sub(r'^  version "[^"]+"$', '  version "1.0.0"',
                               (ROOT / "Casks" / cask.name).read_text(), flags=re.MULTILINE))
        self.files = {}
        for arch, template in package["assets"].items():
            name = template.format(version=version)
            self.files[name] = f"test installer for {arch}".encode()
            digest = hashlib.sha256(self.files[name]).hexdigest()
            checksum = package["checksums"].format(asset=name, version=version)
            self.files[checksum] = self.files.get(checksum, b"") + f"{digest}  {name}\n".encode()
        release = {
            "tag_name": f"v{version}", "draft": False, "prerelease": "-" in version,
            "assets": [{"name": name, "state": "uploaded",
                        "digest": "sha256:" + hashlib.sha256(data).hexdigest()}
                       for name, data in self.files.items()],
        }
        return cask, package, release

    def download(self, *arguments):
        folder = Path(arguments[arguments.index("--dir") + 1])
        for name, data in self.files.items():
            (folder / name).write_bytes(data)
        return ""

    def test_all_package_layouts_update_every_architecture(self):
        for token in self.packages:
            with self.subTest(token=token):
                cask, package, release = self.fixture(token)
                with patch.object(UPDATER, "gh", side_effect=self.download):
                    updated = UPDATER.prepare_update(cask, package, release)
                self.assertIn('version "9.0.0"', updated)
                for template in package["assets"].values():
                    digest = hashlib.sha256(self.files[template.format(version="9.0.0")]).hexdigest()
                    self.assertIn(digest, updated)
                self.assertNotEqual(cask.read_text(), updated)

    def test_bad_download_or_manifest_is_rejected(self):
        for corrupt_manifest in (False, True):
            cask, package, release = self.fixture("ontop")
            original = cask.read_text()
            target = "SHA256SUMS" if corrupt_manifest else "OnTop-9.0.0-universal.dmg"
            self.files[target] = b"corrupted"
            with patch.object(UPDATER, "gh", side_effect=self.download), self.assertRaises(ValueError):
                UPDATER.prepare_update(cask, package, release)
            self.assertEqual(cask.read_text(), original)

    def test_missing_architecture_fails_before_downloading(self):
        cask, package, release = self.fixture("marknote")
        release["assets"] = release["assets"][1:]
        with patch.object(UPDATER, "gh") as download, self.assertRaises(ValueError):
            UPDATER.prepare_update(cask, package, release)
        download.assert_not_called()

    def test_changed_existing_release_is_rejected(self):
        cask, package, release = self.fixture("ontop", "1.0.0")
        with self.assertRaisesRegex(ValueError, "without a version bump"):
            UPDATER.prepare_update(cask, package, release)

    def test_downgrade_is_ignored(self):
        cask, package, release = self.fixture("ontop", "0.1.0")
        with patch.object(UPDATER, "gh") as download:
            self.assertEqual(UPDATER.prepare_update(cask, package, release), cask.read_text())
        download.assert_not_called()

    def test_stable_cask_rejects_prerelease(self):
        cask, package, release = self.fixture("ontop", "9.0.0-rc.1")
        with self.assertRaisesRegex(ValueError, "channel mismatch"):
            UPDATER.prepare_update(cask, package, release)

    def test_keycraft_accepts_release_candidate(self):
        cask, package, release = self.fixture("keycraft", "9.0.0-rc.1")
        with patch.object(UPDATER, "gh", side_effect=self.download):
            self.assertIn('version "9.0.0-rc.1"', UPDATER.prepare_update(cask, package, release))

    def test_version_ordering_and_draft_filter(self):
        versions = ["1.0.0-rc.2", "1.0.0-rc.10", "1.0.0", "1.0.1"]
        self.assertEqual(sorted(reversed(versions), key=UPDATER.version_key), versions)
        releases = [{"tag_name": "v" + version, "draft": False} for version in versions]
        releases.append({"tag_name": "v99.0.0", "draft": True})
        with patch.object(UPDATER, "gh", return_value=json.dumps(releases)):
            self.assertEqual(UPDATER.latest_release(self.packages["keycraft"])["tag_name"], "v1.0.1")

    def test_failure_leaves_all_casks_unchanged(self):
        (self.folder / "Casks").mkdir()
        (self.folder / "packages.json").write_text(json.dumps(self.packages))
        for token in self.packages:
            name = f"{token}.rb"
            (self.folder / "Casks" / name).write_text((ROOT / "Casks" / name).read_text())
        original = (self.folder / "Casks/ontop.rb").read_text()
        with patch.object(UPDATER, "ROOT", self.folder), \
             patch.object(UPDATER, "latest_release", return_value={}), \
             patch.object(UPDATER, "prepare_update", side_effect=["updated", ValueError("failed")]), \
             self.assertRaises(ValueError):
            UPDATER.main()
        self.assertEqual((self.folder / "Casks/ontop.rb").read_text(), original)


if __name__ == "__main__":
    unittest.main(verbosity=2)
