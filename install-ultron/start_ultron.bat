@echo off
title ULTRON
cd /d "%~dp0"
if exist ".venv\Scripts\pythonw.exe" (
    start "" ".venv\Scripts\pythonw.exe" main.py --startup
) else (
    start "" pythonw main.py --startup
)
exit /b 0
