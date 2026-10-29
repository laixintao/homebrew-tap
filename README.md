# laixintao's Homebrew Tap

Install my macOS apps and command-line tools with [Homebrew](https://brew.sh).
Casks download published installers; formulae build versioned source archives.
Both verify SHA-256 checksums.

## Available software

| App | Description | Requirements | Install |
| --- | --- | --- | --- |
| <a href="https://github.com/laixintao/agentdeck"><img src="docs/assets/icons/agentdeck.png" width="48" height="48" alt=""><br>AgentDeck</a> | Monitor local AI agents, live output, context usage, and task status. | macOS 14+; Apple Silicon or Intel | `brew install --cask laixintao/tap/agentdeck` |
| <a href="https://github.com/laixintao/freecell-on-mac"><img src="docs/assets/icons/freecell.png" width="48" height="48" alt=""><br>FreeCell</a> | Native FreeCell solitaire with drag-and-drop, undo, and saved games. | macOS 13+; Apple Silicon or Intel | `brew install --cask laixintao/tap/freecell` |
| <a href="https://github.com/laixintao/gazelift"><img src="docs/assets/icons/gazelift.png" width="48" height="48" alt=""><br>GazeLift</a> | Look-away reminders with expanding screen borders. | macOS 14+; Apple Silicon or Intel | `brew install --cask laixintao/tap/gazelift` |
| <a href="https://github.com/laixintao/keycraft"><img src="docs/assets/icons/keycraft.png" width="48" height="48" alt=""><br>Keycraft</a> | Review and explore Vim and tmux shortcuts. | macOS 12+; Apple Silicon or Intel | `brew install --cask laixintao/tap/keycraft` |
| <a href="https://github.com/laixintao/marknote"><img src="docs/assets/icons/marknote.png" width="48" height="48" alt=""><br>Marknote</a> | Native Markdown editor with live preview. | macOS 13+; Apple Silicon or Intel | `brew install --cask laixintao/tap/marknote` |
| <a href="https://github.com/laixintao/ontop"><img src="docs/assets/icons/ontop.png" width="48" height="48" alt=""><br>OnTop</a> | Keep live window previews always on top. | macOS 14+; Apple Silicon or Intel | `brew install --cask laixintao/tap/ontop` |
| <a href="https://github.com/laixintao/speaker-timer"><img src="docs/assets/icons/speaker-timer.png" width="48" height="48" alt=""><br>Speaker Timer</a> | Always-on-top presentation timer with section checkpoints. | macOS 14+; Apple Silicon or Intel | `brew install --cask laixintao/tap/speaker-timer` |
| [MouseSpeedKeeper](https://github.com/laixintao/MouseSpeedKeeper) | Keep Logitech hardware DPI consistent; optional user background service. | macOS; Xcode Command Line Tools 14+; compatible Logitech mouse | `brew install laixintao/tap/mouse-speed-keeper` |

The fully qualified install commands add this tap automatically. You can also add
it explicitly with `brew tap laixintao/tap`.

**Release channels:** AgentDeck, FreeCell, GazeLift, OnTop, Marknote, and Speaker Timer track stable releases. Keycraft currently
ships release candidates, so its cask tracks the newest version, including RCs.

Marknote keeps the original app bundle name supplied by its developer, which is
displayed in Chinese in Finder.

## MouseSpeedKeeper (CLI formula)

This package installs `mouse-speed` from source; no bottle is published yet.
It does not alter DPI, create/overwrite your configuration, or start a service during installation.
Follow the [project setup guide](https://github.com/laixintao/MouseSpeedKeeper#readme)
to capture your mouse's identity and configure DPI before starting:

```sh
brew services start laixintao/tap/mouse-speed-keeper
```

Use a user service (no `sudo`). Configuration and logs live in
`~/Library/Application Support/MouseSpeedKeeper/`.

Update with `brew upgrade laixintao/tap/mouse-speed-keeper`, then
`brew services restart laixintao/tap/mouse-speed-keeper`.
To uninstall, stop the service first, then `brew uninstall laixintao/tap/mouse-speed-keeper`.
Your configuration and logs are retained.

The existing `packages.json` and six-hour updater are **cask-only**. This source
formula is updated explicitly for each immutable upstream release; see
[the CLI formula release process](docs/CLI_FORMULAS.md). It is not a DMG app and
does not use the GUI-app release asset contract below.

## First launch (GUI apps)

Current releases of these apps are ad-hoc signed and are not notarized by Apple.
If macOS blocks an app you trust, attempt to open it, then use **System Settings >
Privacy & Security > Open Anyway** as described in
[Apple's instructions](https://support.apple.com/en-us/102445).
The casks do not disable Gatekeeper or remove quarantine attributes.

If you previously installed an app manually, Homebrew may report that the app
already exists. Keep a copy if needed, quit the app, and move that existing app
out of Applications before installing through Homebrew. Your preferences are
preserved unless you explicitly use `--zap`.

## Update or uninstall

For example, to update OnTop:

```sh
brew update
brew upgrade --cask laixintao/tap/ontop
```

To uninstall it while keeping preferences:

```sh
brew uninstall --cask laixintao/tap/ontop
```

Replace `ontop` with `agentdeck`, `freecell`, `gazelift`, `keycraft`, `marknote`, or `speaker-timer` for the other apps. To also remove
the app data listed in its cask, use `brew uninstall --cask --zap`; this can delete
settings and other saved app data.

## Maintenance

The **Update casks** workflow checks upstream releases every six hours and can
also be run manually from the Actions tab. It uses this repository's
`GITHUB_TOKEN`; no personal access token or cross-repository secret is needed.

For each new version, the updater downloads every supported installer, checks it
against the upstream checksum file and GitHub's asset digest when available,
then updates the cask's version and hashes. Missing assets or mismatched checksums
stop the update before any cask is written. Older releases never downgrade a cask.
Cask tests, style checks, and audits run before the workflow commits an update.

New applications should follow the [macOS release and Homebrew onboarding standard](docs/RELEASE_STANDARD.md).
It defines version tags, asset names, checksum manifests, provenance, immutable publishing,
the common `make release` command, and the tap integration checklist. Each application's
`make release` prepares and pushes the next version automatically from a clean `main` branch;
CI publishes it, and this tap synchronizes afterward. Copyable workflow and configuration examples live under
[`templates/macos-app`](templates/macos-app).

Release asset patterns and channels are defined in [packages.json](packages.json). The primary
configuration for every app follows the standard contract; exact-version `legacy` entries keep
already-published releases installable while a project migrates. After adding a cask, add its
update configuration there and list it in the table above.

Run the local checks with Python 3.9+ and Homebrew:

```sh
python3 -m unittest discover -s tests -v
brew style "$PWD"/Casks/*.rb
brew audit --cask --strict --skip-style --tap=laixintao/tap
```

The audit checks the installed tap. Use `brew tap laixintao/tap` first, or develop
inside `$(brew --repository laixintao/tap)` so it audits your working changes.

With [GitHub CLI](https://cli.github.com) authenticated, check for updates locally:

```sh
python3 scripts/update_casks.py
```

App issues belong in the linked upstream repositories. Report installation or
tap automation issues in [this repository](https://github.com/laixintao/homebrew-tap/issues).
