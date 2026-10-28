cask "agentdeck" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.1"
  sha256 arm:   "bfb50e0115b6e7bca8b88ec30efee4044004a8c1ce6e797bc990bfea7c4dd397",
         intel: "a8dbdf6cb5bf089bc4a3fc743bb6a3efc6d0f1d22220f3fb0efbba652fa76932"

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
