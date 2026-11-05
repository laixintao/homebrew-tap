cask "marknote" do
  arch arm: "arm64", intel: "x86_64"

  version "1.2.5"
  sha256 arm:   "93e78c94229b5a564b6d90bd85f2ef61e1b9406b28815b3dddeac32d6acfe056",
         intel: "cd74cd71e1d680dbd57b44a63c9721f0beb8b614156faf7902ce7a1257fd15a3"

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
