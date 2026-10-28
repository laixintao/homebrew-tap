cask "agentdeck" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.5"
  sha256 arm:   "6af321fd956ad9b080ba1377e4c5245b8db734f6ade2c068c2cde5b11d395bfc",
         intel: "98863c4c60a98402d048fd78869d67a2c4859917bbf3306a2daf5d5305b8e4e2"

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
