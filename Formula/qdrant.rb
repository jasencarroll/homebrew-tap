class Qdrant < Formula
  desc "Vector similarity search engine with extended filtering support"
  homepage "https://qdrant.tech"
  license "Apache-2.0"
  version "1.17.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/qdrant/qdrant/releases/download/v#{version}/qdrant-aarch64-apple-darwin.tar.gz"
      sha256 "43feed023b4737a509f81dbe695afbb355346a4884482fe1026d23f4d68ab183"
    else
      url "https://github.com/qdrant/qdrant/releases/download/v#{version}/qdrant-x86_64-apple-darwin.tar.gz"
      sha256 "1e826b058c4b5a83cc937ffc02135405beffd96161bd4fcda9f97a59b659d712"
    end
  end

  def install
    bin.install "qdrant"
  end

  service do
    run [opt_bin/"qdrant"]
    keep_alive true
    log_path var/"log/qdrant.log"
    error_log_path var/"log/qdrant.err"
    working_dir var/"qdrant"
  end

  def post_install
    (var/"qdrant/storage").mkpath
    (var/"qdrant/snapshots").mkpath
  end

  test do
    assert_match "qdrant #{version}", shell_output("#{bin}/qdrant --version 2>&1")
  end
end
