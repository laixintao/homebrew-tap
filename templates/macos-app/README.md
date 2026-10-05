# macOS application release template

Copy `.github/workflows` into a new application repository, then replace the `make` commands with
the project's equivalents. The template assumes these project commands:

| Command | Contract |
| --- | --- |
| `make release-validate RELEASE_TAG=v1.2.3` | Validate the tag, embedded version, changelog, and notes without changing files. |
| `make ci-package` | Test and create this runner's standard DMG, ZIP, and temporary checksum data in `dist/releases`. |
| `make release-verify RELEASE_TAG=v1.2.3 ARTIFACT_DIR=dist/releases` | Verify all downloaded architectures and create `SHA256SUMS`. No network writes. |
| `make release-publish RELEASE_TAG=v1.2.3 ARTIFACT_DIR=dist/releases` | Resume/create a draft, upload verified files plus `SHA256SUMS`, and publish only after success. |

Choose stable or RC tag matching in `release.yml`, and remove the Intel matrix row only when the
project produces a genuinely universal binary. Read the full
[release and onboarding standard](../../docs/RELEASE_STANDARD.md) before enabling the workflow.
