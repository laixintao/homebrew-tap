class MouseSpeedKeeper < Formula
  desc "Keep Logitech mouse hardware DPI consistent on macOS"
  homepage "https://github.com/laixintao/MouseSpeedKeeper"
  url "https://github.com/laixintao/MouseSpeedKeeper/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "7a6ed58fa73f1b628d7e126c3cd3559ee7aaeccf775dd37e95ddec2414a837c9"

  depends_on xcode: ["14.0", :build]
  depends_on :macos

  def install
    # Keep the SDK paired with xcrun's compiler when Xcode and CLT differ.
    ENV["SDKROOT"] = Utils.safe_popen_read("/usr/bin/xcrun", "--sdk", "macosx", "--show-sdk-path").strip
    system "bash", "scripts/build.sh"
    bin.install ".build/mouse-speed"
    pkgshare.install "config.example.json"
    doc.install "docs/configuration.md"
  end

  def caveats
    <<~EOS
      Installation does not change DPI or start the service.
      Create your configuration before starting (do not overwrite an existing one):
        mkdir -p "$HOME/Library/Application Support/MouseSpeedKeeper"
        if [ ! -e "$HOME/Library/Application Support/MouseSpeedKeeper/config.json" ]; then
          mouse-speed capture "$HOME/Library/Application Support/MouseSpeedKeeper/config.json"
        fi
      Edit the dpi field, preserving your mouse's identity, then run:
        brew services start laixintao/tap/mouse-speed-keeper
      After editing configuration:
        brew services restart laixintao/tap/mouse-speed-keeper

      Use a user service, not sudo. See the project README for setup.
      Configuration and logs remain in ~/Library/Application Support/MouseSpeedKeeper.
    EOS
  end

  service do
    name macos: "homebrew.mxcl.mouse-speed-keeper"
    run [opt_bin/"mouse-speed", "watch", "#{Dir.home}/Library/Application Support/MouseSpeedKeeper/config.json"]
    keep_alive true
    log_path "#{Dir.home}/Library/Application Support/MouseSpeedKeeper/agent.log"
    error_log_path "#{Dir.home}/Library/Application Support/MouseSpeedKeeper/error.log"
  end

  test do
    # Exercise argument validation without requiring a mouse or changing DPI.
    assert_match "Usage: mouse-speed", shell_output("#{bin}/mouse-speed invalid-command 2>&1", 1)
    (testpath/"invalid.json").write('{"dpi":0,"identity":"1234abcd"}')
    assert_match "Invalid configuration", shell_output("#{bin}/mouse-speed apply #{testpath}/invalid.json 2>&1", 1)
  end
end
