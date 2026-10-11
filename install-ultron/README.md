# ULTRON — one-command install

Brahma AI Evo, rebranded and hardened as **ULTRON** for MO.

## Install on your Windows PC
```powershell
# 1. get these files anywhere, then:
powershell -ExecutionPolicy Bypass -File .\INSTALL_ULTRON.ps1
```
Defaults to **`N:\MY AGENTS\ULTRON`**. Override:
```powershell
.\INSTALL_ULTRON.ps1 -Dest "N:\MY AGENTS\ULTRON"
```
Then launch: `N:\MY AGENTS\ULTRON\start_ultron.bat`

## What the installer does
1. Clones the app into the target folder.
2. Creates a Python venv + installs deps + Playwright.
3. Seeds your **golden rules** into `%LOCALAPPDATA%\BrahmaAI\config\learned_rules.json`.
4. Seeds shared **memory** at `%LOCALAPPDATA%\BrahmaAI\memory\`.
5. Runs the **regression gate** (compile check). Fails → not installed.

## Where ULTRON keeps state (this is your memory fix)
- Long-term memory: `%LOCALAPPDATA%\BrahmaAI\memory\long_term.json`
- Learned rules: `%LOCALAPPDATA%\BrahmaAI\config\learned_rules.json`

## License note
Brahma AI Evo is *source-available, personal use only, no redistribution*.
So its source is **not committed here** — only these installer files. ULTRON is gitignored.
