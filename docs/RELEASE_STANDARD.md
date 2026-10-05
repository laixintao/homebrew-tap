# macOS release and Homebrew onboarding standard

This is the release contract for applications distributed by `laixintao/tap`. It standardizes
the public boundary between an application repository and this tap while allowing each project
to use its own language, build system, signing setup, and test suite.

## Maintainer command

Every application must expose the same daily release entry point:

```sh
git switch main
git pull --ff-only
make release
```

Commit/merge application changes first. From a clean `main` worktree, plain `make release` must:

1. Check the remote history and tag conflicts before editing files.
2. Choose the next patch version in the project's existing channel, updating all required version
   fields automatically. An optional `VERSION=<newer-version>` selects a specific version.
3. Generate the required changelog/release notes from commit history, or preserve already committed
   curated notes. Projects using GitHub-generated notes may generate them in the publishing job.
4. Create a release commit and annotated version tag, then atomically push `main` and that tag.
5. Print the Actions link and return after pushing. Actions builds and publishes the release;
   check that workflow before treating the release as available.

No separate `make version`, changelog edit, release commit, tag, upload, or tap edit is required.
An optional prepare-only command must not change the default behavior of plain `make release`.
If pushing fails, keep the release commit/tag and print the exact push command to retry. Do not
run `make release` again to retry the same version. Never move or overwrite a published tag.

| Project | Plain `make release` | Optional explicit version |
| --- | --- | --- |
| OnTop | Next stable patch, e.g. `1.3.2` → `1.3.3` | `make release VERSION=1.4.0` |
| Marknote | Next stable patch, e.g. `1.2.1` → `1.2.2` | `make release VERSION=1.3.0` |
| Keycraft | Next patch RC, e.g. `0.4.1-rc.1` → `0.4.2-rc.1` | `make release VERSION=0.5.0-rc.1` |

Keycraft's `make rc` remains an optional way to increment the current candidate. It is not a
required step in the daily SOP. The common command does not change a project's release channel.

After the upstream Release succeeds, the tap checks it on the next six-hour schedule. To sync
immediately, run [Update casks](https://github.com/laixintao/homebrew-tap/actions/workflows/update-casks.yml)
manually. Once the cask update is committed, users run `brew update` and
`brew upgrade --cask laixintao/tap/<token>`.

For new implementations, use the [OnTop release helper](https://github.com/laixintao/ontop/blob/main/scripts/release.py),
[Marknote helper](https://github.com/laixintao/marknote/blob/main/Scripts/release.py), or
[Keycraft helper](https://github.com/laixintao/keycraft/blob/main/scripts/bumpversion.cjs) as a reference.
Test the actual Make target against a disposable local Git remote, including rejected pushes,
dirty worktrees, version validation, and tag conflicts, without creating a real release.

## Public release contract

Use SemVer tags with a leading `v`:

- Stable: `v1.2.3`
- Release candidate: `v1.2.3-rc.1`

The application version embedded in the bundle must exactly match the tag without `v`. A release
must publish either a universal pair or both architecture-specific pairs:

```text
<Product>-<version>-macos-universal.dmg
<Product>-<version>-macos-universal.zip
```

or:

```text
<Product>-<version>-macos-arm64.dmg
<Product>-<version>-macos-arm64.zip
<Product>-<version>-macos-x86_64.dmg
<Product>-<version>-macos-x86_64.zip
```

`Product` uses the application's display capitalization. Public architecture names are `arm64`,
`x86_64`, and `universal`; build-tool names such as Electron's `x64` stay internal.

Every release also publishes one `SHA256SUMS` file in the format emitted by:

```sh
shasum -a 256 <files...> > SHA256SUMS
```

Do not publish per-file checksum sidecars. They may be used as temporary CI artifacts before the
publishing job combines them into `SHA256SUMS`.

## Required release boundary

The release workflow follows this order:

1. Validate the tag, embedded version, changelog, and release notes.
2. Build and test on `macos-15` (Apple Silicon) and, for split packages, `macos-15-intel`.
3. Package the tested application; do not rebuild separately in the publishing job.
4. Verify every downloaded artifact, its checksum, signature, embedded version, and architecture.
5. Generate `SHA256SUMS` and GitHub build-provenance attestations for DMG and ZIP files.
6. Create or resume a draft GitHub Release, upload every asset, then make it public.

Published release assets are immutable. A retry may resume a draft but must never replace a public
release. Publish a new version when any binary changes. Stable releases are marked latest;
prereleases are marked prerelease and are not latest.

Pin third-party GitHub Actions to full commit SHAs. Default workflow permissions to
`contents: read`; grant `contents: write`, `id-token: write`, and `attestations: write` only to the
publishing job. Set release concurrency per tag and never cancel an in-progress tag release.

## Repository shape

Keep normal CI separate from publishing and reuse the same build workflow from both paths:

```text
.github/workflows/
├── ci.yml
├── build.yml       # workflow_call; produces verified packages
└── release.yml     # validate → build → verify → attest → publish
```

For small projects, `ci.yml` itself may be the reusable `workflow_call` build workflow, as long as
the release consumes the exact tested artifacts. See [`templates/macos-app`](../templates/macos-app)
for a copyable starting point. The template expects project-specific commands for version
validation, building, artifact verification, and draft publication; its README lists the contract.

## Connect a project to this tap

1. Implement `make release` with the maintainer contract above, then merge and exercise the release
   workflow in the application repository.
2. Add `Casks/<token>.rb` with the minimum supported macOS version, bundle name, bundle identifier,
   uninstall behavior, and optional zap paths.
3. Add the project to `packages.json` using the standard asset names and `SHA256SUMS`. Set
   `include_prereleases` only when the tap intentionally tracks release candidates.
4. If the current public release predates this standard, add an exact-version `legacy` override.
   The updater uses the legacy files for that version and switches the cask URL to the standard
   contract when the next release appears.
5. Add the application to the README table and to the install/uninstall list in CI.
6. Run the updater tests, `brew style`, strict `brew audit`, and an install/uninstall test on both
   Apple Silicon and Intel.

The tap updater runs every six hours. It downloads all expected DMGs and checksum manifests,
compares the downloaded SHA-256 with both the manifest and GitHub's asset digest, updates the cask
atomically, then runs style and audit checks before committing. A missing architecture or checksum
blocks the whole update.

## Existing reference implementations

- OnTop: universal package and provenance attestation.
- Marknote: split `arm64` / `x86_64` native builds.
- Keycraft: split Electron builds with internal `x64` to public `x86_64` translation and an RC
  release channel.
