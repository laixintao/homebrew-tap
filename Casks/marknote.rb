cask "marknote" do
  arch arm: "arm64", intel: "x86_64"

  version "1.2.0"
  sha256 arm:   "2762e6108c5665b4c75a03b3c1c4cb9e80abee9286b6234a1a767c7489b98874",
         intel: "4111b94afcdfa34f69aadea284a87d3d25c8fe044fb8241e835399c1ba1895d5"

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
