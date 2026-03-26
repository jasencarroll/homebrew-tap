class Embedd < Formula
  desc "Local embedding server for Roo Code codebase indexing on macOS"
  homepage "https://github.com/jasencarroll/homebrew-tap"
  version "0.1.0"
  license "MIT"

  depends_on "llama.cpp"
  depends_on :macos

  def install
    (bin/"embedd").write <<~'BASH'
      #!/bin/bash
      set -euo pipefail

      EMBEDD_VERSION="0.1.0"
      EMBEDD_PORT="${EMBEDD_PORT:-6334}"
      EMBEDD_HOST="${EMBEDD_HOST:-127.0.0.1}"
      EMBEDD_CONTEXT="${EMBEDD_CONTEXT:-2048}"
      EMBEDD_BATCH="${EMBEDD_BATCH:-512}"
      EMBEDD_UBATCH="${EMBEDD_UBATCH:-512}"
      EMBEDD_GPU_LAYERS="${EMBEDD_GPU_LAYERS:-99}"

      declare -A MODELS=(
        ["qwen3:0.6b"]="Qwen/Qwen3-Embedding-0.6B-GGUF|Qwen3-Embedding-0.6B-Q8_0.gguf|1024"
        ["qwen3:4b"]="Qwen/Qwen3-Embedding-4B-GGUF|Qwen3-Embedding-4B-Q4_K_M.gguf|2560"
        ["qwen3:8b"]="Qwen/Qwen3-Embedding-8B-GGUF|Qwen3-Embedding-8B-Q4_K_M.gguf|4096"
      )
      DEFAULT_MODEL="qwen3:4b"

      resolve() {
        MODEL_ALIAS="${1:-$DEFAULT_MODEL}"
        local entry="${MODELS[$MODEL_ALIAS]:-}"
        if [[ -z "$entry" ]]; then
          echo "error: unknown model '$MODEL_ALIAS'" >&2
          echo "available: ${!MODELS[*]}" >&2
          exit 1
        fi
        IFS='|' read -r HF_REPO HF_FILE DIMS <<< "$entry"
      }

      usage() {
        cat <<EOF
      embedd ${EMBEDD_VERSION} — local embedding server for Roo Code

      USAGE:
        embedd serve [MODEL]        Start embedding server (default: qwen3:4b)
        embedd pull [MODEL]         Download model without starting server
        embedd models               List available models
        embedd config [MODEL]       Print Roo Code configuration
        embedd --version            Print version

      MODELS:
        qwen3:0.6b                  0.6B Q8_0  — 1024 dims, ~640MB
        qwen3:4b                    4B Q4_K_M  — 2560 dims, ~2.5GB
        qwen3:8b                    8B Q4_K_M  — 4096 dims, ~5GB

      ENVIRONMENT:
        EMBEDD_PORT                 Server port (default: 6334)
        EMBEDD_HOST                 Bind address (default: 127.0.0.1)
        EMBEDD_CONTEXT              Context length (default: 2048)
        EMBEDD_GPU_LAYERS           GPU offload layers (default: 99)
      EOF
      }

      cmd_pull() {
        resolve "${1:-}"
        echo "pulling ${MODEL_ALIAS} from ${HF_REPO}..."
        llama-cli \
          --hf-repo "${HF_REPO}" \
          --hf-file "${HF_FILE}" \
          -n 0 -p "" --no-warmup 2>/dev/null || true
        echo "done. model cached locally."
      }

      cmd_models() {
        printf "\n  %-12s %-8s %-6s %s\n" "ALIAS" "QUANT" "DIMS" "HF REPO"
        printf "  %-12s %-8s %-6s %s\n" "-----" "-----" "----" "-------"
        for alias in "qwen3:0.6b" "qwen3:4b" "qwen3:8b"; do
          IFS='|' read -r repo file dims <<< "${MODELS[$alias]}"
          local quant
          case "$alias" in
            *0.6b) quant="Q8_0" ;;
            *)     quant="Q4_K_M" ;;
          esac
          printf "  %-12s %-8s %-6s %s\n" "$alias" "$quant" "$dims" "$repo"
        done
        echo ""
      }

      cmd_config() {
        resolve "${1:-}"
        echo ""
        echo "  ROO CODE CODEBASE INDEXING CONFIG"
        echo "  ================================="
        echo "  Embedding Provider:  OpenAI Compatible"
        echo "  Base URL:            http://${EMBEDD_HOST}:${EMBEDD_PORT}/v1"
        echo "  API Key:             x"
        echo "  Model ID:            ${MODEL_ALIAS}"
        echo "  Dimension:           ${DIMS}"
        echo "  Qdrant URL:          http://localhost:6333"
        echo "  Qdrant API Key:      (leave blank)"
        echo ""
      }

      cmd_serve() {
        resolve "${1:-}"
        echo "embedd ${EMBEDD_VERSION}"
        echo "model:    ${MODEL_ALIAS} (${DIMS} dims)"
        echo "endpoint: http://${EMBEDD_HOST}:${EMBEDD_PORT}/v1/embeddings"
        echo "pooling:  last-token + L2 normalize"
        echo ""

        exec llama-server \
          --hf-repo "${HF_REPO}" \
          --hf-file "${HF_FILE}" \
          --embeddings \
          --pooling last \
          --host "${EMBEDD_HOST}" \
          --port "${EMBEDD_PORT}" \
          --ctx-size "${EMBEDD_CONTEXT}" \
          --batch-size "${EMBEDD_BATCH}" \
          --ubatch-size "${EMBEDD_UBATCH}" \
          --n-gpu-layers "${EMBEDD_GPU_LAYERS}" \
          --flash-attn
      }

      case "${1:-}" in
        serve)        cmd_serve "${2:-}" ;;
        pull)         cmd_pull "${2:-}" ;;
        models)       cmd_models ;;
        config)       cmd_config "${2:-}" ;;
        --version|-v) echo "embedd ${EMBEDD_VERSION}" ;;
        --help|-h|"") usage ;;
        *)            echo "unknown command: $1" >&2; usage; exit 1 ;;
      esac
    BASH
    chmod 0755, bin/"embedd"
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
