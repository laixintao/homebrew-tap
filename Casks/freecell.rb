cask "freecell" do
  arch arm: "arm64", intel: "x86_64"

  version "1.0.1"
  sha256 arm:   "349f80e16e4b2b5909360450a6a32710c255a7155c8ccd416266ca05d87415d8",
         intel: "cb3363af9db84dcaaa32d1821b6a180a1358031271ba0cdd7fa99859b4163a53"

  url "https://github.com/laixintao/freecell-on-mac/releases/download/v#{version}/FreeCell-#{version}-macos-#{arch}.dmg"
  name "FreeCell"
  desc "Native FreeCell solitaire with undo and saved games"
  homepage "https://github.com/laixintao/freecell-on-mac"

  depends_on macos: :ventura

  app "FreeCell.app"

  uninstall quit: "com.local.freecell"

  zap trash: [
    "~/Library/Application Support/FreeCell",
    "~/Library/Preferences/com.local.freecell.plist",
    "~/Library/Saved Application State/com.local.freecell.savedState",
  ]

  caveats <<~EOS
    FreeCell is not signed with an Apple Developer ID or notarized by Apple.
    If macOS blocks the first launch, follow Apple's instructions:
      https://support.apple.com/en-us/102445
  EOS
end
