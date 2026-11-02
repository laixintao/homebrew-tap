cask "marknote" do
  arch arm: "arm64", intel: "x86_64"

  version "1.2.4"
  sha256 arm:   "3ef83b7183216fccb439472b7e61cf0679ac81a4ab4e3603e6b4e1a86892b1c7",
         intel: "95145b9187a2f1521c93df1c52c9e81c2189500913ca69858c9b18f45ff622fc"

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
