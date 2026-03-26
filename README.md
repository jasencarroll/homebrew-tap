# Homebrew Tap

Homebrew formulae maintained by [@jasencarroll](https://github.com/jasencarroll).

## Install

```bash
brew tap jasencarroll/tap
```

## Available Formulae

| Formula | Description |
|---------|-------------|
| `qdrant` | Vector similarity search engine with extended filtering support |
| `embedd` | Local embedding server for Roo Code codebase indexing on macOS |

## embedd

Wraps `llama-server` (llama.cpp) with Qwen3-Embedding models, last-token pooling, and L2 normalization. Zero API keys, zero cloud.

```bash
brew install embedd
embedd serve                # start on :6334 with qwen3:4b (default)
embedd serve qwen3:0.6b     # lighter model
embedd pull qwen3:4b        # pre-download model
embedd models               # list available models
embedd config               # print Roo Code settings
```

### Run as a service

```bash
brew services start embedd
```

### Models

| Alias | Params | Quant | Dims | Size |
|-------|--------|-------|------|------|
| `qwen3:0.6b` | 0.6B | Q8_0 | 1024 | ~640MB |
| `qwen3:4b` | 4B | Q4_K_M | 2560 | ~2.5GB |
| `qwen3:8b` | 8B | Q4_K_M | 4096 | ~5GB |

### Full local Roo Code indexing stack

```bash
brew install embedd qdrant
brew services start qdrant
brew services start embedd
embedd config
```

## qdrant

```bash
brew install qdrant
brew services start qdrant
```
