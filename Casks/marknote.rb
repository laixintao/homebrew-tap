cask "marknote" do
  arch arm: "arm64", intel: "x86_64"

  version "1.2.3"
  sha256 arm:   "6afdadd27d8a47d8d49ed09ebfac322e1dedbf438aa185a41cb9f95e2a3fcc93",
         intel: "697e4f432f0a09c1793d4cb66ade6316a45f4828a54827c6bc44ce425920241c"

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
