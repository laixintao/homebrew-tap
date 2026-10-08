cask "gazelift" do
  version "0.1.0"
  sha256 "42218925101d83e066ae98400ff52ee695b0618d9bf4ec6ccec3a6ea03bb7360"

  url "https://github.com/laixintao/gazelift/releases/download/v#{version}/GazeLift-#{version}-macos-universal.dmg"
  name "GazeLift"
  desc "Look-away reminders with expanding screen borders"
  homepage "https://github.com/laixintao/gazelift"

  depends_on macos: :sonoma

  app "GazeLift.app"

  uninstall quit: "io.xbin.gazelift"

  zap trash: "~/Library/Preferences/io.xbin.gazelift.plist"

  caveats <<~EOS
    GazeLift is not signed with an Apple Developer ID or notarized by Apple.
    If macOS blocks the first launch, follow Apple's instructions:
      https://support.apple.com/en-us/102445
  EOS
end
