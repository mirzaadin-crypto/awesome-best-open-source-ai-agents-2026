# OSmOS Remote — Telegram control + permission approvals

Run this on your PC. Then, from your phone, you can **approve agent actions** and **run commands**.

## Start it
```powershell
$env:VISKO_TELEGRAM_TOKEN = "<your-bot-token>"   # or set User env var
python osmos_remote.py --agent VISKO
```
Or double-click `start_osmos_remote.bat VISKO`.

## Use it (from Telegram)
| Command | Does |
|---|---|
| `/status` | agents + pending count + memory stats |
| `/run <cmd>` | **creates a permission request** (nothing runs yet) |
| `/approve <id>` | approve → executes → returns output |
| `/deny <id>` | cancel |
| `/pending` | list open requests |
| `/mem search <q>` | search cross-session memory |
| `/mem add <text>` | add to memory |
| `/note <text>` | append memory note |
| `/keepalive` | toggle 30-min heartbeat |

## How permission requests work
1. You (or an agent) send `/run git pull`
2. Bot replies: `PERMISSION REQUEST [a1b2c3] > git pull`
3. You reply `/approve a1b2c3` → it runs, output comes back
4. Dangerous commands are tagged `[DANGEROUS]`

## Safety
- **First chat to message the bot becomes the owner** (stored in `%LOCALAPPDATA%\OSmOS\telegram_allow.json`).
- Everyone else → `unauthorized`.
- Token never hardcoded; env var or local config only.
