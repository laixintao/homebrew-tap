cask "ontop" do
  version "1.3.1"
  sha256 "98d8110d92d6804cc4929fd0b3d403cc11796eea46013781919a955e8d1b985e"

  url "https://github.com/laixintao/ontop/releases/download/v#{version}/OnTop-#{version}-universal.dmg"
  name "OnTop"
  desc "Keep live window previews always on top"
  homepage "https://github.com/laixintao/ontop"

  depends_on macos: :sonoma

  app "OnTop.app"

  uninstall quit: "app.ontop.OnTop"

  zap trash: "~/Library/Preferences/app.ontop.OnTop.plist"

  caveats <<~EOS
    OnTop is not signed with an Apple Developer ID or notarized by Apple.
    If macOS blocks the first launch, follow Apple's instructions:
      https://support.apple.com/en-us/102445
  EOS
end
