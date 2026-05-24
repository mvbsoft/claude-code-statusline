# claude-code-statusline

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/powershell)

A lightweight PowerShell status line for [Claude Code](https://docs.anthropic.com/claude/docs/claude-code) that surfaces the most useful session info at a glance — folder, git branch, model, context usage, rate limits, and cost.

```
📁 my-project | 🌿 main | 🤖 Sonnet 4.6 (12.3K/200K) | 📊 5h (42%) ▰▰▰▰▱▱▱▱▱▱  📊 1w (18%) ▰▱▱▱▱▱▱▱▱▱
```

When the 5-hour rate limit is hit, the cost is shown upfront:

```
💰 $1.24  📊 5h (100%) ▰▰▰▰▰▰▰▰▰▰  📊 1w (31%) ▰▰▰▱▱▱▱▱▱▱
```

## Features

- **📁 Current folder** — shows just the project folder name, not the full path
- **🌿 Git branch** — auto-detected via `git`, hidden when not in a repo
- **🤖 Model name** — current Claude model with 🧠 indicator when extended thinking is on
- **Context bar** — tokens used vs. context window size (e.g. `12.3K/200K`)
- **📊 Rate limits** — 5-hour and 7-day usage as percentage + visual fill bar (`▰▰▰▱▱▱▱▱▱▱`)
- **💰 Session cost** — displayed when the 5-hour rate limit is reached

## Requirements

- Windows with PowerShell 5.1 or later
- [Claude Code](https://docs.anthropic.com/claude/docs/claude-code) CLI installed
- Git (optional — for branch display)

## Installation

### 1. Clone the repo

```powershell
git clone https://github.com/mvbsoft/claude-code-statusline.git
```

Or just download `statusline.ps1` directly.

### 2. Configure Claude Code

Open (or create) `~/.claude/settings.json` and add:

```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\path\\to\\statusline.ps1\""
  }
}
```

Replace `C:\\path\\to\\statusline.ps1` with the actual path where you saved the script.

### 3. Restart Claude Code

The status line appears at the bottom of the terminal on every prompt.

## How it works

Claude Code calls the status line command after each response, piping a JSON payload with session data (model, context window, rate limits, cost, working directory). The script parses this JSON and outputs a single formatted line.

The JSON schema is undocumented but stable. The script handles missing fields gracefully — each section only appears when the data is present.

## Customization

All display logic is in `statusline.ps1`. The bar character width is controlled by `Format-Bar`:

```powershell
function Format-Bar($pct) {
    $filled = [Math]::Min([Math]::Floor($pct / 10), 10)
    return ([string][char]0x25B0) * $filled + ([string][char]0x25B1) * (10 - $filled)
}
```

`0x25B0` is `▰` (filled) and `0x25B1` is `▱` (empty). You can swap in any Unicode block characters you prefer.

## Contributing

Pull requests are welcome. For larger changes, please open an issue first to discuss what you'd like to change.

## License

[MIT](LICENSE) — © 2026 mvbsoft
