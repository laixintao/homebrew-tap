cask "speaker-timer" do
  version "1.0.1"
  sha256 "edaf63a2e6c0269d863c43122a0b11902ae36818ef9f4f102f09bea168068cae"

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
