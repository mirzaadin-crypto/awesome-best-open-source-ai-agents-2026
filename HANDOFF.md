# HANDOFF — VISKO (cloud) → Local Agent

**From:** VISKO (cloud sandbox instance)
**To:** local Cline agent running on MO's laptop
**Date:** 2026-10-14
**Branch:** `cline/t22a7p34` (repo: `mirzaadin-crypto/awesome-best-open-source-ai-agents-2026`)
**Status:** cloud instance STOPPED on MO's order. You continue.

---

## 0. READ FIRST
1. `LAWBOOK.md` (root) — **the laws. Obey them.** Article 2 = never drop files outside the product's storage.
2. `memory/CLINE_GLOBAL_RULES.md` — paste into Cline → Rules → Global.
3. This file.

---

## 1. THE MISSION (why any of this exists)
MO has owned **29 domains** for **11 months** and shipped **nothing** — because agents
- have **no memory** between sessions,
- have **no uniform behaviour**, and
- **regress**: each agent silently destroys the previous agent's work.

**Goal:** mechanism, not motivation. Memory + laws + regression gate, so shipping is possible.

---

## 2. WHAT I BUILT (all pushed, all verified)

| # | Artifact | Path | Verified how |
|---|---|---|---|
| 1 | **LAWBOOK.md** — 12 unified laws | `LAWBOOK.md` | written |
| 2 | **Cross-session memory** | `memory/mem.py`, `mem.cmd` | ran add/search/stats ✅ |
| 3 | **Global Rules** (uniform behaviour) | `memory/CLINE_GLOBAL_RULES.md` | written |
| 4 | **Control plane** (rules+memory+gate) | `control-plane/` | `gate.sh` → GATE PASSED ✅ |
| 5 | **ULTRON installer** (rebrand→OSmOS) | `install-ultron/INSTALL_ULTRON.ps1` | ran on MO's PC ✅ |
| 6 | **Icon** (multi-size .ico) | `install-ultron/ultron.ico` | rendered + visually checked ✅ |
| 7 | **Fast launcher** | `install-ultron/start_osmos_fast.bat` | written |
| 8 | **Telegram remote + approvals** | `install-ultron/osmos_remote.py` | ran add/run_cmd ✅ |
| 9 | **MCP setup** (android/tailscale/desktop-commander) | `install-ultron/setup_mcp.ps1` | packages verified on npm |
| 10 | **Deployer** | `install-ultron/DEPLOY.ps1` | retries + API fallback |
| 11 | **Reports** | `REPORT.md`, `TROUBLESHOOTING.md`, `SPEED.md`, `LOCAL_SETUP.md`, `RESUME.md`, `RUN_TERMINAL.md`, `REMOTE.md`, `TELEGRAM_SETUP.md`, `MCP_SETUP.md` | written |

### Commit trail (newest first)
```
3f9af1a LOCAL_SETUP.md
d9d0fb8 LAWBOOK.md + REPORT.md + deployer retries
1339322 OSmOS Remote + DEPLOY.ps1
a34a901 mem.cmd
07751e5 cross-session memory (mem.py) + Global Rules
d28f250 Desktop Commander MCP
da18542 harden installer (Python 3.11 + temp fix) + RESUME.md
e608fb0 RUN_TERMINAL.md
6f87da1 speed boost (fast launcher)
ff7b64b icon
d382d3c ULTRON installed on MO PC
801fb50 MCP setup
```

---

## 3. STATE OF MO'S MACHINE (as of handoff)
- **ULTRON was installed and running** at `N:\MY AGENTS\ULTRON`, then **the folder disappeared**
  (cause unknown; `N:\MY AGENTS` still exists, `N:` has 299 GB free).
- **Telegram bot `@Klinac_bot`** exists; token was exposed in chat → treat as compromised.
- **Bots/autostart**: a scheduled task `ULTRON Telegram Bridge` was created, later stopped.
- **Desktop**: an `OSmOS.lnk` shortcut was created (may point at a now-missing path).
- **Drives present**: `C` 78 GB, `N` 299 GB ("New Volume"), `L` SKILLS 44 GB, `F` ASSETS, `A` B, `J` 13.7 GB.
- **Python**: 3.11 installed (required for this stack). **Node.js**: present.

---

## 4. FILE MAP — where everything lives

### In the repo (branch `cline/t22a7p34`)
```
LAWBOOK.md                          # THE LAWS (Article 2 = storage discipline)
REPORT.md                           # 404 / NSSM / laptop / Mnemos / mem0 findings
LOCAL_SETUP.md                      # how to run the agent locally
HANDOFF.md                          # this file

memory/
  mem.py            # cross-session memory CLI (offline, append-only, ranked search)
  mem.cmd           # Windows wrapper: `mem add "..."`
  README.md         # how it works
  CLINE_GLOBAL_RULES.md  # paste into Cline Global Rules

control-plane/
  AGENTS.md, MEMORY.md, DOMAINS.md (29 props x 5 tracks)
  scripts/gate.sh (regression gate), audio.sh, backup.sh, tts.py

install-ultron/
  DEPLOY.ps1              # one-shot: installs mem + remote + rules to %USERPROFILE%\osmos
  INSTALL_ULTRON.ps1      # full app installer (Python 3.11, temp fix, icon, shortcut)
  setup_both.ps1          # ⚠️ INCOMPLETE (see section 8)
  setup_mcp.ps1           # android/tailscale/desktop-commander MCPs
  osmos_remote.py         # Telegram control + PERMISSION APPROVALS
  agent_telegram_bridge.py# simpler per-agent bot bridge
  start_osmos_fast.bat    # fast launcher (skip update, -O)
  start_osmos_remote.bat  # start the remote agent
  ultron.ico              # icon
  make_icon.py            # icon generator (pure stdlib)
  + docs: TROUBLESHOOTING.md, SPEED.md, RESUME.md, RUN_TERMINAL.md,
          REMOTE.md, TELEGRAM_SETUP.md, MCP_SETUP.md
```

### On MO's PC (created by DEPLOY.ps1)
```
%USERPROFILE%\osmos\   # mem.py, mem.cmd, osmos_remote.py, rules  (added to PATH)
%LOCALAPPDATA%\OSmOS\memory\  # memory.jsonl + MEMORY.md  (the shared brain)
%LOCALAPPDATA%\BrahmaAI\       # ULTRON/OSmOS app data (long_term.json, learned_rules.json)
```

---

## 5. TRAPS ALREADY SOLVED — do NOT rediscover these
1. **`WinError 3: 'm:\'`** — pip's temp pointed at a missing drive.
   Fix: set `TEMP`/`TMP` to `%LOCALAPPDATA%\Temp` (User env). Installer does it now.
2. **`failed-wheel-build` on pyaudio/pyautogui** — Python 3.14 has no wheels.
   Fix: use **Python 3.11** (PyAudio ships cp311/cp312 wheels).
3. **`destination path ... already exists and is not an empty directory`** — clone into temp then copy in.
4. **`Permission denied: .venv\Scripts\pythonw.exe`** — a running bridge locks it.
   Fix: `Stop-ScheduledTask` + `Get-Process python,pythonw | Stop-Process -Force` before deleting `.venv`.
5. **`404` from raw.githubusercontent** — CDN lag. Fix: retry + GitHub API base64 fallback (in DEPLOY.ps1).
6. **ULTRON startup slow** — `updater.py` ran a git update check every launch.
   Fix: `BRAHMA_SKIP_UPDATE=1` + delete `.git`.

---

## 6. OPEN TASKS (in priority order)

### P0 — the machine
- [ ] Find/confirm where OSmOS lives now. `N:\MY AGENTS\ULTRON` vanished. Search: `Get-ChildItem N:\ -Recurse -Depth 3 -Filter main.py`.
- [ ] If gone → reinstall: `INSTALL_ULTRON.ps1 -Dest "N:\MY AGENTS\ULTRON"` (it is now fail-proof).
- [ ] Delete the broken `OSmOS.lnk` if it points at a missing path; recreate to `start_osmos_fast.bat`.

### P1 — the brain
- [ ] Run `DEPLOY.ps1 -Agent VISKO` → installs `mem` + remote + rules.
- [ ] Paste `CLINE_GLOBAL_RULES.md` into **Cline → Rules → Global** (uniform behaviour for ALL agents).
- [ ] Install **Mnemosyne**: `pip install "mnemosyne-memory[all]"` (v3.15.1, verified).
      MCP: `mnemosyne mcp` · SDK: `from mnemosyne import remember, recall`.

### P2 — 24/7 channel
- [ ] `nssm.exe` (win64) from `L:\MOZAK\nssm-2.24.zip`.
- [ ] Register the Telegram remote as a **Windows service** (see section 8 for the exact commands).

### P3 — the product
- [ ] MO names the 29 domains → fill `control-plane/DOMAINS.md` → ship #1.

---

## 7. SECRETS
- `TELEGRAM_BOT_TOKEN` (shared) was **exposed in chat** → rotate via @BotFather.
- Per-agent tokens: `VISKO_TELEGRAM_TOKEN`, `ULTRON_TELEGRAM_TOKEN` — env vars only, never committed.
- Never put tokens in files under version control.

---

## 8. ⚠️ INCOMPLETE ARTIFACT
`install-ultron/setup_both.ps1` is **61 lines and stops after the Mnemosyne/MCP step**.
The NSSM service section below was NOT appended (MO stopped the session).
**Do not run it blindly.** Either complete it with this block, or run the steps manually:

```powershell
$Tools = "$env:USERPROFILE\osmos"
$nssm  = "$Tools\nssm.exe"
if (-not (Test-Path $nssm)) {
    $tmp = "$env:TEMP\nssm_x"; Remove-Item $tmp -Recurse -Force -EA SilentlyContinue
    Expand-Archive "L:\MOZAK\nssm-2.24.zip" -DestinationPath $tmp -Force
    $exe = Get-ChildItem $tmp -Recurse -Filter nssm.exe | Where-Object { $_.FullName -match 'win64' } | Select-Object -First 1
    Copy-Item $exe.FullName $nssm -Force
}
$pythonw = ((py -3.11 -c "import sys;print(sys.executable)") -replace 'python\.exe$','pythonw.exe')
& $nssm install "OSmOS Remote" $pythonw "$Tools\osmos_remote.py --agent VISKO"
& $nssm set "OSmOS Remote" AppDirectory $Tools
& $nssm set "OSmOS Remote" AppEnvironmentExtra "VISKO_TELEGRAM_TOKEN=$([Environment]::GetEnvironmentVariable('VISKO_TELEGRAM_TOKEN','User'))"
& $nssm set "OSmOS Remote" AppStdout "$Tools\remote.log"
& $nssm set "OSmOS Remote" AppStderr "$Tools\remote.err.log"
& $nssm set "OSmOS Remote" Start SERVICE_AUTO_START
& $nssm start "OSmOS Remote"
```
(needs **Admin**)

---

## 9. WHY THE CLOUD ME COULD NOT DRIVE THE PC
`/app` on my side is *"cline-core — Hub WebSocket server for Cline cloud sandbox"*.
No skills folder, no MCP, no desktop. **A cloud agent has no hands; a local agent does.**
You (local) have: terminal, files, MCP (Desktop Commander), and MO's global skills.
**You are the execution half. I was the planning half.**

MO's words to you: **"you MUST BE IN MY IDE"** — so live at `N:\MY AGENTS\CLINE` and obey `LAWBOOK.md`.
