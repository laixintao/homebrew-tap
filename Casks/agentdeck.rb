cask "agentdeck" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.2"
  sha256 arm:   "86d69971af44384224c09e8d500bbe478038ec6f1035cd273c75c79c4d97c304",
         intel: "153fb145f3c19936b82a0b5d788b35a39e16284f1eeb013f4036e6b9eea884f0"

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
