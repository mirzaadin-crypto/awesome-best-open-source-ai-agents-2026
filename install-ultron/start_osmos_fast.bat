@echo off
rem =====================================================================
rem  OSmOS fast launcher — skips update/network checks, optimized bytecode
rem =====================================================================
cd /d "%~dp0"

set BRAHMA_SKIP_UPDATE=1
set PYTHONOPTIMIZE=1
set PYTHONUTF8=1
set PYTHONDONTWRITEBYTECODE=

if exist ".venv\Scripts\pythonw.exe" (
    start "OSmOS" ".venv\Scripts\pythonw.exe" -O main.py
) else (
    start "OSmOS" pythonw -O main.py
)
exit /b 0
