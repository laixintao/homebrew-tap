cask "marknote" do
  arch arm: "arm64", intel: "x86_64"

  version "1.2.1"
  sha256 arm:   "4b243b41cf7454c87025178fbec65530e2090755befa21a132a396e39e365637",
         intel: "c7b6007209f1f402f42e9636ddf72ad1d16f477c7720155e0d234b14813f59c2"

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
