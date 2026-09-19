cask "ontop" do
  version "1.2.0"
  sha256 "fa07f61fc73441203df94a9a6b776455385bb2de850766d1b3e0804282cc3189"

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
