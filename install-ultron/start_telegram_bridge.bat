@echo off
title ULTRON Telegram Bridge
cd /d "%~dp0"
set /p TK=<..\telegram_token.txt 2>nul
if defined TK (set TELEGRAM_BOT_TOKEN=%TK%)
if exist ".venv\Scripts\python.exe" (
  ".venv\Scripts\python.exe" install-ultron\ultron_telegram_bridge.py
) else (
  python "install-ultron\ultron_telegram_bridge.py"
)
pause
