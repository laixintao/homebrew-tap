cask "ontop" do
  version "1.3.0"
  sha256 "1d0c2a59306dcf77165671954be69b22cfc08231c0a61679ae94e6828394c628"

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
