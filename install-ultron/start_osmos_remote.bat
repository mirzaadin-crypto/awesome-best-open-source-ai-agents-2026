@echo off
rem OSmOS Remote - Telegram control + permission approvals (runs on your PC)
cd /d "%~dp0"
set AGENT=%1
if "%AGENT%"=="" set AGENT=VISKO
set PY=pythonw
if exist "..\.venv\Scripts\pythonw.exe" set PY=..\.venv\Scripts\pythonw.exe
start "OSmOS Remote %AGENT%" %PY% osmos_remote.py --agent %AGENT%
exit /b 0
