cask "keycraft" do
  arch arm: "arm64", intel: "x64"

  version "0.4.1-rc.1"
  sha256 arm:   "fa7c69755a850b6751eec1b0df6c18a3e0566fa5eaca6b079ffcb6c6ec867af0",
         intel: "49571f2370404b26cc5c7a1be44f369a9d2259a9641af72268690040847e1879"

  url "https://github.com/laixintao/keycraft/releases/download/v#{version}/keycraft-#{version}-macos-#{arch}.dmg"
  name "keycraft"
  desc "Review and explore Vim and tmux shortcuts"
  homepage "https://github.com/laixintao/keycraft"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+(?:-rc\.\d+)?)$/i)
    strategy :github_releases do |json, regex|
      json.filter_map do |release|
        next if release["draft"]

        release["tag_name"]&.[](regex, 1)
      end
    end
  end

  depends_on macos: :monterey

  app "keycraft.app"

  uninstall quit: "io.xbin.keycraft"

  zap trash: [
    "~/Library/Application Support/keycraft",
    "~/Library/Preferences/io.xbin.keycraft.plist",
    "~/Library/Saved Application State/io.xbin.keycraft.savedState",
  ]

  caveats <<~EOS
    Keycraft is not signed with an Apple Developer ID or notarized by Apple.
    If macOS blocks the first launch, follow Apple's instructions:
      https://support.apple.com/en-us/102445
  EOS
end
