# ULTRON install — troubleshooting (solved)

Known failure modes hit during first install, and the fixes.

## 1. `fatal: destination path ... already exists and is not an empty directory`
Old installer ran `git clone` into a non-empty folder.
**Fix:** clone to a temp dir, then copy in. (Installer v2.)

## 2. `WinError 3: The system cannot find the path specified: 'm:\\'`
pip's build temp pointed at a **non-existent `M:\` drive**.
**Fix:** force a real temp dir (permanent):
```powershell
$t="$env:LOCALAPPDATA\Temp"; $env:TEMP=$t; $env:TMP=$t
[Environment]::SetEnvironmentVariable('TEMP',$t,'User')
[Environment]::SetEnvironmentVariable('TMP',$t,'User')
```

## 3. `error: failed-wheel-build-for-install` on pyautogui/pyaudio/etc.
Python **3.14** has no prebuilt wheels → forced source builds.
**Fix:** use Python **3.11** (ULTRON requires 3.11/3.12). PyAudio ships cp311/cp312 wheels.

## 4. `Permission denied: ...\.venv\Scripts\pythonw.exe`
A **running** ULTRON bridge held `pythonw.exe` locked.
**Fix:** stop the task + kill processes before deleting `.venv`:
```powershell
Stop-ScheduledTask -TaskName "ULTRON Telegram Bridge" -EA SilentlyContinue
Get-Process python,pythonw -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
```

## The working install (Python 3.11)
```powershell
cd "N:\MY AGENTS\ULTRON"
$t="$env:LOCALAPPDATA\Temp"; $env:TEMP=$t; $env:TMP=$t
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install --no-cache-dir -r requirements.txt
.\.venv\Scripts\python.exe -m playwright install
.\.venv\Scripts\python.exe main.py --startup
```

**Status: ULTRON installed + running on MO's PC.** ✅
