@echo off
title ULTRON Installer
echo Installing ULTRON to N:\MY AGENTS\ULTRON ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/mirzaadin-crypto/awesome-best-open-source-ai-agents-2026/cline/t22a7p34/install-ultron/INSTALL_ULTRON.ps1'; Invoke-WebRequest $u -OutFile \"$env:TEMP\i.ps1\"; & \"$env:TEMP\i.ps1\""
echo.
echo Done. Press any key to close.
pause >nul
