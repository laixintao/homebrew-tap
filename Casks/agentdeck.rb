cask "agentdeck" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.10"
  sha256 arm:   "0f452cb910d4c4ea2b43d2122fa42dcc48d6b06c0ec3f586529cec4213ca4985",
         intel: "b725107aba5e31ed41869de92c9485c2e820707a73e8a7165023d5d7820a3e60"

  url "https://github.com/laixintao/agentdeck/releases/download/v#{version}/AgentDeck-#{version}-macos-#{arch}.dmg"
  name "AgentDeck"
  desc "Monitor local AI agents, live output, and context usage"
  homepage "https://github.com/laixintao/agentdeck"

  depends_on formula: "tmux"
  depends_on macos: :sonoma

  app "AgentDeck.app"
  binary "#{appdir}/AgentDeck.app/Contents/MacOS/agentdeckctl"

  uninstall quit: "app.agentdeck.mac"

  zap trash: [
    "~/Library/Application Support/AgentDeck",
    "~/Library/Preferences/app.agentdeck.mac.plist",
  ]

  caveats <<~EOS
    AgentDeck is not signed with an Apple Developer ID or notarized by Apple.
    If macOS blocks the first launch, follow Apple's instructions:
      https://support.apple.com/en-us/102445
  EOS
end
