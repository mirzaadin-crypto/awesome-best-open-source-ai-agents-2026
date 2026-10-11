# ULTRON Telegram Bridge — setup

Control ULTRON from `t.me/Klinac_bot` and log everything to memory.

## 1. Store the token SAFELY (never in code, never in git)
On your PC, in a terminal **in the ULTRON folder**:
```powershell
[Environment]::SetEnvironmentVariable("TELEGRAM_BOT_TOKEN","<your-token>","User")
```
Or create `%LOCALAPPDATA%\BrahmaAI\config\telegram.json`:
```json
{ "token": "<your-token>" }
```

## 2. Run the bridge
```
python install-ultron\ultron_telegram_bridge.py
```
(or double-click `install-ultron\start_telegram_bridge.bat`)

## 3. Talk to your bot
Open `t.me/Klinac_bot` → send `/help`

| Command | Does |
|---|---|
| `/status` | ULTRON state (memory + rules count) |
| `/rules` | list learned rules |
| `/remember <text>` | add a golden rule |
| `/note <text>` | append to shared memory |
| `/help` | show commands |

## 🔐 Security
- This token was shared in chat. **Rotate it** after setup: @BotFather → `/revoke`.
- The token lives in an env var / local config — **never committed**.
