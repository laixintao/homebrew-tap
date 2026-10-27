# Source-built CLI formulae

`Formula/` contains command-line packages. `Casks/`, `packages.json`, and the
six-hour `update-casks.py` automation remain dedicated to GUI applications.
The DMG/ZIP contract in RELEASE_STANDARD.md does not apply to source formulae.

## MouseSpeedKeeper

- Formula: `Formula/mouse-speed-keeper.rb`.
- Upstream: `laixintao/MouseSpeedKeeper`, currently branch `master`.
- Versioned source: immutable SemVer `vX.Y.Z` tag archive with SHA-256.
- Build: Xcode Command Line Tools 14+ / Swift, native to the installing Mac.
- No bottles or binary release assets yet. No `make release` automation yet.
- Service: explicitly named `homebrew.mxcl.mouse-speed-keeper`, user-only setup.
- Installation never captures hardware configuration or starts a service.
- Configuration/logs live outside the Cellar, in the user's existing
  `~/Library/Application Support/MouseSpeedKeeper/` directory.

## Releasing an update

1. Commit, test, and push upstream changes. Build the actual tagged commit with
   `bash scripts/build.sh`; test invalid input without hardware access. If
   testing a mouse, use `probe` for read-only verification.
2. Create a new annotated `vX.Y.Z` tag and GitHub release. Never move a published
   tag or overwrite an existing release to repair a package.
3. Download that tag's archive from GitHub. Compute SHA-256 from those exact
   downloaded bytes, not from a separately generated local tarball.
4. Update the formula URL and sha256 together. A same-version packaging-only
   change may need a Homebrew `revision` bump.
5. Run from this checkout (registered as `laixintao/tap`):

   ```sh
   python3 -m unittest discover -s tests -v
   brew style Formula/mouse-speed-keeper.rb
   brew audit --strict --skip-style laixintao/tap/mouse-speed-keeper
   brew install --build-from-source laixintao/tap/mouse-speed-keeper
   brew test laixintao/tap/mouse-speed-keeper
   ```

   If installed already, use `brew reinstall --build-from-source` instead.
   Check generated service arguments and paths without starting a second keeper.
   CI runs source install/test/uninstall on Apple Silicon and Intel runners;
   no physical mouse or background service is needed for those tests.
6. Commit and push the tap change, then verify CI and the remote formula content.
   Users run `brew update`, `brew upgrade laixintao/tap/mouse-speed-keeper`,
   and restart their user service if running.

Do not add this formula to `packages.json`: the current updater expects GUI
installer assets. Source-formula version updates are manual until a dedicated
updater is implemented. Never claim a scheduled cask update will release it.
