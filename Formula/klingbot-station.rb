# Template for the klingtech/homebrew-tools tap. The station-kit release stamps 1.0.0,
# 7cabb8b19d53f6b4843217e3b5f855abaecfe3f6f1bd15d9a4b3e235ae5f6530 and https://fleet.klingworld.com/operator-api/v1/station-kit/1.0.0 and proposes the result to the tap; never edit the tap's copy by hand.
#
# Fleet's Factory page hands a signed-in operator the command with a fresh 10-minute token:
#   HOMEBREW_KLINGBOT_TOKEN=<token> brew install klingtech/tools/klingbot-station
# Homebrew passes HOMEBREW_* variables through, and Fleet serves the kit only for a live token.
class KlingbotStation < Formula
  desc "Klingbot factory station: flashes and finishes Klingbots for the Fleet console"
  homepage "https://fleet.klingworld.com/"
  url "https://fleet.klingworld.com/operator-api/v1/station-kit/1.0.0",
      headers: ["X-Station-Kit-Token: #{ENV.fetch("HOMEBREW_KLINGBOT_TOKEN", "")}"]
  version "1.0.0"
  sha256 "7cabb8b19d53f6b4843217e3b5f855abaecfe3f6f1bd15d9a4b3e235ae5f6530"

  depends_on "node"
  depends_on "open-ocd"
  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]
    (bin/"klingbot-station").write <<~SH
      #!/bin/bash
      # State (.env, uploaded images, private logs) lives in ~/Library/Application Support/Klingbot.
      export PATH="#{Formula["node"].opt_bin}:#{Formula["open-ocd"].opt_bin}:$PATH"
      exec "#{venv}/bin/python" "#{opt_libexec}/klingbot.py" station "$@"
    SH
  end

  # The Python packages go in a venv outside the keg, made after install: pip wheels carry their own dylibs
  # (libusb-package's), and Homebrew's relocation of a keg cannot rewrite their headers.
  def post_install
    home = var/"klingbot-station"
    # Older versions' venvs go; this version's is made fresh.
    home.children.each { |old| rm_r old if old.directory? && old.basename.to_s != version.to_s } if home.exist?
    rm_r venv if venv.exist?
    venv.dirname.mkpath
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", venv
    system venv/"bin/python", "-m", "pip", "install", "--disable-pip-version-check", "--no-input",
           "--require-hashes", "--no-deps", "-r", opt_libexec/"tools/firmware/requirements.lock"
  end

  def venv
    var/"klingbot-station"/version.to_s/"venv"
  end

  def caveats
    <<~EOS
      Start the station with: klingbot-station
      Then open Fleet's Factory page. A J-Link probe also needs SEGGER's J-Link software.
    EOS
  end

  test do
    system bin/"klingbot-station", "--setup-only"
  end
end
