cask "speaker-timer" do
  version "1.0.4"
  sha256 "8a0d55ddd8629f2753f9546a9518127d4fe9534ffe47b9c5eae4038b28e10730"

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
