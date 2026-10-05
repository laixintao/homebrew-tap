# macOS application release template

Copy `.github/workflows` into a new application repository, then replace the `make` commands with
the project's equivalents. The template assumes these project commands:

| Command | Contract |
| --- | --- |
| `make release` | From clean `main`, choose the next version, generate required notes, commit, tag, and atomically push. No manual version preparation. Return after push and print the Actions link. |
| `make release VERSION=1.3.0` | Use a specific newer version in the project's release channel; otherwise follow the same transaction. |
| `make release-validate RELEASE_TAG=v1.2.3` | Validate the tag, embedded version, changelog, and notes without changing files. |
| `make ci-package` | Test and create this runner's standard DMG, ZIP, and temporary checksum data in `dist/releases`. |
| `make release-verify RELEASE_TAG=v1.2.3 ARTIFACT_DIR=dist/releases` | Verify all downloaded architectures and create `SHA256SUMS`. No network writes. |
| `make release-publish RELEASE_TAG=v1.2.3 ARTIFACT_DIR=dist/releases` | Resume/create a draft, upload verified files plus `SHA256SUMS`, and publish only after success. |

Choose stable or RC tag matching in `release.yml`, and remove the Intel matrix row only when the
project produces a genuinely universal binary. Read the full
[release and onboarding standard](../../docs/RELEASE_STANDARD.md) before enabling the workflow.
