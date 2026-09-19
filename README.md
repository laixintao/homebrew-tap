# laixintao's Homebrew Tap

Install my macOS apps with [Homebrew](https://brew.sh). Packages download the
installers published in each project's GitHub Releases and verify their SHA-256 checksums.

## Available software

| App | Description | Requirements | Install |
| --- | --- | --- | --- |
| [Keycraft](https://github.com/laixintao/keycraft) | Review and explore Vim and tmux shortcuts. | macOS 12+; Apple Silicon or Intel | `brew install --cask laixintao/tap/keycraft` |
| [Marknote](https://github.com/laixintao/marknote) | Native Markdown editor with live preview. | macOS 13+; Apple Silicon or Intel | `brew install --cask laixintao/tap/marknote` |
| [OnTop](https://github.com/laixintao/ontop) | Keep live window previews always on top. | macOS 14+; Apple Silicon or Intel | `brew install --cask laixintao/tap/ontop` |

The fully qualified install commands add this tap automatically. You can also add
it explicitly with `brew tap laixintao/tap`.

**Release channels:** OnTop and Marknote track stable releases. Keycraft currently
ships release candidates, so its cask tracks the newest version, including RCs.

Marknote keeps the original app bundle name supplied by its developer, which is
displayed in Chinese in Finder.

## First launch

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

Replace `ontop` with `keycraft` or `marknote` for the other apps. To also remove
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

Release asset patterns and channels are defined in [packages.json](packages.json).
After adding a cask, add its update configuration there and list it in the table above.

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
