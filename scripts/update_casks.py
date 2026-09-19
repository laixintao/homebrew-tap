#!/usr/bin/env python3
"""Update casks from upstream GitHub releases after verifying every installer."""

import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
VERSION = re.compile(r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-([0-9A-Za-z.-]+))?")


def version_key(version):
    match = VERSION.fullmatch(version)
    if not match:
        raise ValueError(f"Unsupported release version: {version!r}")
    major, minor, patch, prerelease = match.groups()
    identifiers = tuple((0, int(part)) if part.isdigit() else (1, part)
                        for part in prerelease.split(".")) if prerelease else ()
    return (int(major), int(minor), int(patch), prerelease is None, identifiers)


def gh(*args):
    return subprocess.check_output(["gh", *args], text=True, timeout=300)


def latest_release(package):
    repository = package["repository"]
    if package["include_prereleases"]:
        releases = json.loads(gh("api", f"repos/{repository}/releases?per_page=100"))
        candidates = []
        for release in releases:
            version = release["tag_name"].removeprefix("v")
            if not release["draft"] and VERSION.fullmatch(version):
                candidates.append(release)
        if not candidates:
            raise ValueError(f"No versioned releases found for {repository}")
        return max(candidates, key=lambda item: version_key(item["tag_name"].removeprefix("v")))
    return json.loads(gh("api", f"repos/{repository}/releases/latest"))


def replace_once(pattern, replacement, text):
    updated, count = re.subn(pattern, replacement, text, flags=re.MULTILINE)
    if count != 1:
        raise ValueError(f"Expected one matching cask field: {pattern}")
    return updated


def checksum_pattern(architecture):
    if architecture == "universal":
        return r'^(  sha256 ")[0-9a-f]{64}("\s*)$'
    return rf'^(\s+(?:sha256 )?{architecture}:\s+")[0-9a-f]{{64}}("[,]?\s*)$'


def sha256_file(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def expected_checksum(text, asset):
    matches = re.findall(rf"^([0-9a-fA-F]{{64}}) [ *](?:\./)?{re.escape(asset)}$",
                         text, flags=re.MULTILINE)
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one checksum for {asset}")
    return matches[0].lower()


def prepare_update(cask, package, release):
    text = cask.read_text()
    current_match = re.search(r'^  version "([^"]+)"$', text, re.MULTILINE)
    if not current_match:
        raise ValueError(f"Missing version in {cask.name}")
    current = current_match[1]
    version = release["tag_name"].removeprefix("v")
    if release["draft"] or (release["prerelease"] and not package["include_prereleases"]):
        raise ValueError(f"Release channel mismatch for {cask.stem}: {version}")
    if version_key(version) < version_key(current):
        print(f"{cask.stem}: keeping newer version {current}")
        return text

    # Resolve every expected asset before downloading or changing any cask.
    assets = {asset["name"]: asset for asset in release["assets"]}
    installers = {arch: template.format(version=version)
                  for arch, template in package["assets"].items()}
    checksum_files = {name: package["checksums"].format(version=version, asset=name)
                      for name in installers.values()}
    names = sorted(set(installers.values()) | set(checksum_files.values()))
    for name in names:
        if name not in assets or assets[name]["state"] != "uploaded":
            raise ValueError(f"Missing uploaded release asset: {name}")

    if version == current:
        # An existing release must never silently acquire a different checksum.
        for arch, name in installers.items():
            match = re.search(checksum_pattern(arch), text, re.MULTILINE)
            if not match:
                raise ValueError(f"Missing {arch} checksum in {cask.name}")
            recorded = re.search(r'[0-9a-f]{64}', match[0])[0]
            digest = assets[name].get("digest")
            if digest and digest != f"sha256:{recorded}":
                raise ValueError(f"Published asset changed without a version bump: {name}")
        print(f"{cask.stem}: already at {version}")
        return text

    with tempfile.TemporaryDirectory(prefix=f"{cask.stem}-release-") as temporary:
        folder = Path(temporary)
        arguments = ["release", "download", release["tag_name"], "--repo", package["repository"],
                     "--dir", temporary]
        for name in names:
            arguments.extend(["--pattern", name])
        gh(*arguments)
        for arch, name in installers.items():
            digest = sha256_file(folder / name)
            expected = expected_checksum((folder / checksum_files[name]).read_text(), name)
            if digest != expected:
                raise ValueError(f"Checksum mismatch for {name}")
            github_digest = assets[name].get("digest")
            if github_digest and github_digest != f"sha256:{digest}":
                raise ValueError(f"GitHub asset digest mismatch for {name}")
            text = replace_once(checksum_pattern(arch),
                                lambda match: match[1] + digest + match[2], text)
    text = replace_once(r'^  version "[^"]+"$', f'  version "{version}"', text)
    print(f"{cask.stem}: {current} -> {version} (all installer checksums verified)")
    return text


def main():
    packages = json.loads((ROOT / "packages.json").read_text())
    updates = {}
    for token, package in packages.items():
        cask = ROOT / "Casks" / f"{token}.rb"
        updates[cask] = prepare_update(cask, package, latest_release(package))
    # A failed download or checksum leaves every cask untouched.
    for path, content in updates.items():
        if path.read_text() != content:
            path.write_text(content)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"Update failed: {error}", file=sys.stderr)
        sys.exit(1)
