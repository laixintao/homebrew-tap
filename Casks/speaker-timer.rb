cask "speaker-timer" do
  version "1.0.2"
  sha256 "0a5cb568bc96f5426619a218e153917a8b2e8c214797dc79143c7b51e2f5dddc"

  url "https://github.com/laixintao/speaker-timer/releases/download/v#{version}/Speaker-Timer-#{version}-macos-universal.dmg"
  name "Speaker Timer"
  desc "Always-on-top presentation timer with section checkpoints"
  homepage "https://github.com/laixintao/speaker-timer"

  depends_on macos: :sonoma

  app "Speaker Timer.app"

  uninstall quit: "io.xbin.speaker-timer"

  zap trash: [
    "~/Library/Application Support/Speaker Timer",
    "~/Library/Preferences/io.xbin.speaker-timer.plist",
  ]

  caveats <<~EOS
    Speaker Timer is not signed with an Apple Developer ID or notarized by Apple.
    If macOS blocks the first launch, follow Apple's instructions:
      https://support.apple.com/en-us/102445
  EOS
end
