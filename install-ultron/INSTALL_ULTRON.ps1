# =====================================================================
#  ULTRON Installer  (Brahma AI Evo -> ULTRON)
#  Default install path: N:\MY AGENTS\ULTRON
#  Run:  powershell -ExecutionPolicy Bypass -File .\INSTALL_ULTRON.ps1
# =====================================================================
param(
    [string]$Dest = "N:\MY AGENTS\ULTRON",
    [string]$Repo = "https://github.com/mirzaadin-crypto/Brahma-Ai-Evo.git"
)

$ErrorActionPreference = "Stop"
Write-Host "== ULTRON installer ==" -ForegroundColor Cyan
Write-Host "Target: $Dest" -ForegroundColor Yellow

# 1. Destination
if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Force -Path $Dest | Out-Null }
Set-Location $Dest

# 2. Get the app (clone only if this script is not already inside the app)
if (-not (Test-Path (Join-Path $Dest "main.py"))) {
    Write-Host "Cloning source..." -ForegroundColor Cyan
    if (Test-Path (Join-Path $Dest ".git")) { git -C $Dest pull } else { git clone $Repo $Dest }
}

# 3. Python
$Python = if (Get-Command py -ErrorAction SilentlyContinue) { "py" }
          elseif (Get-Command python -ErrorAction SilentlyContinue) { "python" }
          else { throw "Python 3.11/3.12 not found. Install from python.org first." }

# 4. Virtual environment + deps
if (-not (Test-Path "$Dest\.venv\Scripts\python.exe")) {
    Write-Host "Creating venv..." -ForegroundColor Cyan
    & $Python -m venv .venv
}
$VP = "$Dest\.venv\Scripts\python.exe"
& $VP -m pip install --upgrade pip setuptools wheel
& $VP -m pip install -r requirements.txt
& $VP -m playwright install

# 5. Seed ULTRON identity + MO golden rules + memory
$DataDir = Join-Path $env:LOCALAPPDATA "BrahmaAI"
New-Item -ItemType Directory -Force -Path "$DataDir\config" | Out-Null
New-Item -ItemType Directory -Force -Path "$DataDir\memory" | Out-Null
if (Test-Path "$Dest\mo_golden_rules.json") {
    Copy-Item "$Dest\mo_golden_rules.json" "$DataDir\config\learned_rules.json" -Force
}
if (-not (Test-Path "$DataDir\memory\MEMORY.md")) {
    "date | agent | change | why | next" | Out-File "$DataDir\memory\MEMORY.md" -Encoding utf8
}

# 6. Regression gate (must pass before it counts as installed)
Write-Host "Running regression gate (compile check)..." -ForegroundColor Cyan
& $VP -m compileall -q "$Dest"
if ($LASTEXITCODE -ne 0) { throw "Regression gate FAILED. ULTRON not installed." }
Write-Host "Gate passed." -ForegroundColor Green

Write-Host ""
Write-Host "ULTRON installed at $Dest" -ForegroundColor Green
Write-Host "Launch:  $Dest\start_ultron.bat" -ForegroundColor Yellow
Write-Host "Memory:  $DataDir\memory\long_term.json" -ForegroundColor Yellow
Write-Host "Rules:   $DataDir\config\learned_rules.json" -ForegroundColor Yellow
