class Embedd < Formula
  desc "Local embedding server for Roo Code codebase indexing on macOS"
  homepage "https://github.com/jasencarroll/embedd"
  url "https://github.com/jasencarroll/embedd/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d9e45756cdf8804b8422fe59ab8af74e43c655bfa992618f9fc78d3eca1ec564"
  license "MIT"

  depends_on "llama.cpp"
  depends_on :macos

  def install
    bin.install "bin/embedd"
  end

  service do
    run [opt_bin/"embedd", "serve"]
    keep_alive true
    log_path var/"log/embedd.log"
    error_log_path var/"log/embedd.err"
    working_dir HOMEBREW_PREFIX
  end

  def caveats
    <<~EOS
      Start the embedding server:
        embedd serve

      Or run as a background service:
        brew services start embedd

      First run downloads ~2.5GB model. See Roo Code config:
        embedd config
    EOS
  end

  test do
    assert_match "embedd", shell_output("#{bin}/embedd --version")
  end
end
