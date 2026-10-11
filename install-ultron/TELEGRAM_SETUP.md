# Telegram Bridge — one bot per agent

Each agent has its **own** bot and its **own** token. Nothing is shared.

| Agent | Token env var | Task name |
|---|---|---|
| ULTRON | `ULTRON_TELEGRAM_TOKEN` | ULTRON Telegram Bridge |
| VISKO | `VISKO_TELEGRAM_TOKEN` | VISKO Telegram Bridge |

## Set an agent's token (per agent, never shared)
```powershell
[Environment]::SetEnvironmentVariable("VISKO_TELEGRAM_TOKEN","<visko-token>","User")
[Environment]::SetEnvironmentVariable("ULTRON_TELEGRAM_TOKEN","<ultron-token>","User")
```

## Run one bridge manually
```powershell
python install-ultron\agent_telegram_bridge.py --agent VISKO
python install-ultron\agent_telegram_bridge.py --agent ULTRON
```

## Auto-start an agent's bot at boot
```powershell
powershell -ExecutionPolicy Bypass -File .\install-ultron\install_boot_autostart.ps1 -Agent VISKO
```

## Remove a token / bot entirely
```powershell
Stop-ScheduledTask -TaskName "ULTRON Telegram Bridge" -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "ULTRON Telegram Bridge" -Confirm:$false -ErrorAction SilentlyContinue
[Environment]::SetEnvironmentVariable("TELEGRAM_BOT_TOKEN",$null,"User")
[Environment]::SetEnvironmentVariable("ULTRON_TELEGRAM_TOKEN",$null,"User")
```

## Security
Tokens live in **env vars / local config only** — never in code, never committed.
