cask "speaker-timer" do
  version "1.0.5"
  sha256 "9a7ca22849c1c6d1f7b824babd381387e477a4a290b075767173f34d9090a0fb"

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
