cask "marknote" do
  arch arm: "arm64", intel: "x86_64"

  version "1.2.2"
  sha256 arm:   "7a315ebd4c2de4e8ae054599a24643f05b4d9ae0b948af387b923ef591412407",
         intel: "3a2ecc345c7dae52c6bcd1c6534c7b70358345c5e5d81ee110d053a261a7f550"

  url "https://github.com/laixintao/marknote/releases/download/v#{version}/Marknote-#{version}-macos-#{arch}.dmg"
  name "Marknote"
  desc "Native Markdown editor with live preview"
  homepage "https://github.com/laixintao/marknote"

  depends_on macos: :ventura

  app "\u58a8\u7b3a.app"

  uninstall quit: "net.marknote.editor"

  zap trash: "~/Library/Preferences/net.marknote.editor.plist"

  caveats <<~EOS
    Marknote is not signed with an Apple Developer ID or notarized by Apple.
    If macOS blocks the first launch, follow Apple's instructions:
      https://support.apple.com/en-us/102445
  EOS
end
