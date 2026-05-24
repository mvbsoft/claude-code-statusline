# claude-code-statusline

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Windows-PowerShell%205.1%2B-blue?logo=powershell)](statusline.ps1)
[![Linux](https://img.shields.io/badge/Linux-Bash-orange?logo=gnu-bash)](statusline.sh)

A lightweight status line for [Claude Code](https://docs.anthropic.com/claude/docs/claude-code) that shows the most useful session info at a glance — folder, git branch, model, context usage, rate limits, and session cost.

```
📁 my-project | 🌿 main | 🤖 Sonnet 4.6 (12.3K/200K) | 📊 5h (42%) ▰▰▰▰▱▱▱▱▱▱  📊 1w (18%) ▰▱▱▱▱▱▱▱▱▱
```

When the 5-hour rate limit is reached, the session cost appears upfront:

```
💰 $1.24  📊 5h (100%) ▰▰▰▰▰▰▰▰▰▰  📊 1w (31%) ▰▰▰▱▱▱▱▱▱▱
```

## Features

| | |
|---|---|
| **📁 Folder** | Current project folder (not the full path) |
| **🌿 Branch** | Git branch, auto-detected — hidden when not in a repo |
| **🤖 Model** | Active Claude model; 🧠 appears when extended thinking is on |
| **Context** | Tokens used vs. window size — `12.3K/200K` |
| **📊 Rate limits** | 5-hour and 7-day usage with a visual fill bar `▰▰▰▱▱▱▱▱▱▱` |
| **💰 Cost** | Session cost in USD, shown once the 5-hour limit is hit |

## Installation

### Windows (PowerShell)

**Requirements:** Windows with PowerShell 5.1+, [Claude Code](https://docs.anthropic.com/claude/docs/claude-code), Git (optional)

**1. Download the script**

```powershell
git clone https://github.com/mvbsoft/claude-code-statusline.git
```

Or download [`statusline.ps1`](statusline.ps1) directly.

**2. Configure Claude Code**

Open `%USERPROFILE%\.claude\settings.json` (create it if it doesn't exist) and add:

```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\path\\to\\statusline.ps1\""
  }
}
```

Replace `C:\\path\\to\\statusline.ps1` with the actual path to the script.

**3. Restart Claude Code** — the status line appears at the bottom of every prompt.

---

### Linux / macOS (Bash)

**Requirements:** Bash, [`jq`](https://stedolan.github.io/jq/), [Claude Code](https://docs.anthropic.com/claude/docs/claude-code), Git (optional)

Install `jq` if you don't have it:

```bash
# Debian / Ubuntu
sudo apt install jq

# Fedora / RHEL
sudo dnf install jq

# macOS
brew install jq
```

**1. Download the script**

```bash
git clone https://github.com/mvbsoft/claude-code-statusline.git
```

Or download [`statusline.sh`](statusline.sh) directly.

**2. Make it executable**

```bash
chmod +x /path/to/statusline.sh
```

**3. Configure Claude Code**

Open `~/.claude/settings.json` (create it if it doesn't exist) and add:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /path/to/statusline.sh"
  }
}
```

Replace `/path/to/statusline.sh` with the actual path to the script.

**4. Restart Claude Code** — the status line appears at the bottom of every prompt.

---

## How it works

Claude Code calls the status line command after each response, piping a JSON payload with session data: model, context window, rate limits, cost, and working directory. The script parses this JSON and outputs a single formatted line.

Each section only renders when the relevant data is present — missing fields are silently skipped.

## Customization

The visual fill bar is built from two Unicode block characters:

| Character | Code | Meaning |
|---|---|---|
| `▰` | U+25B0 | Filled segment |
| `▱` | U+25B1 | Empty segment |

You can swap these for any characters you like. On Windows, edit `Format-Bar` in `statusline.ps1`; on Linux/macOS, edit `format_bar` in `statusline.sh`.

## Contributing

Pull requests are welcome. For larger changes, please open an issue first to discuss what you'd like to change.

## License

[MIT](LICENSE) — © 2026 mvbsoft
