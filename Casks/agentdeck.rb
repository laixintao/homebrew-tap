cask "agentdeck" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.8"
  sha256 arm:   "8df3f9bbfeebf753a21bd598e3a6f7b7ae1f0e5ae46b96de917cf791d6af56cc",
         intel: "42ccd85bec62f5d2f20d285923d1b26fd5a7fcef766e750a8b8a33276322352e"

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
