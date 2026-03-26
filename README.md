# Homebrew Tap

Homebrew formulae maintained by [@jasencarroll](https://github.com/jasencarroll).

## Install

```bash
brew tap jasencarroll/tap
brew install qdrant
```

## Available Formulae

| Formula | Description |
|---------|-------------|
| `qdrant` | Vector similarity search engine with extended filtering support |

## Start as a service

```bash
brew services start qdrant
```

This registers Qdrant as a launchd service that starts on login and restarts on crash.

## Update

```bash
brew update && brew upgrade qdrant
```

Or if you have `homebrew/autoupdate` configured, it handles this automatically.
