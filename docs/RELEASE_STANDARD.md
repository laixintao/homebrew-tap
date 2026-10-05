# macOS release and Homebrew onboarding standard

This is the release contract for applications distributed by `laixintao/tap`. It standardizes
the public boundary between an application repository and this tap while allowing each project
to use its own language, build system, signing setup, and test suite.

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

1. Merge and exercise the release workflow in the application repository.
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
