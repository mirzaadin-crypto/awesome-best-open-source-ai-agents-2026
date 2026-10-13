# OSmOS — speed boost

Three verified startup costs, and how they're removed.

## What was slowing it down
1. **GitHub update check on every launch** (`main.py:5197` → `updater.py`). Your install
   kept a `.git` folder pointing at a *wrong* upstream → git network calls every start.
2. **No prebuilt bytecode** → Python recompiles `.py` on first import.
3. Runs without optimizations.

## The fix (fast launcher)
`start_osmos_fast.bat` sets:
- `BRAHMA_SKIP_UPDATE=1` → no update/network call (updater.py already honors it)
- `PYTHONOPTIMIZE=1` (`-O`) → strips asserts
- `pythonw -O main.py` → no console window

## One-time boost (run once)
```powershell
cd "N:\MY AGENTS\ULTRON"
.\.venv\Scripts\python.exe -m compileall -q .      # precompile bytecode
Remove-Item .git -Recurse -Force -EA SilentlyContinue   # kill the git update path
```

## Result
- No network wait at startup
- Imports served from cached `.pyc`
- Fewer per-run checks

Re-launch via the **OSmOS** desktop shortcut (points at `start_osmos_fast.bat`).
