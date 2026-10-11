# =====================================================================
#  ULTRON Installer  (Brahma AI Evo -> ULTRON)
#  Default install path: N:\MY AGENTS\ULTRON
#  One-line run (paste in PowerShell):
#    powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/mirzaadin-crypto/awesome-best-open-source-ai-agents-2026/cline/t22a7p34/install-ultron/INSTALL_ULTRON.ps1 -OutFile $env:TEMP\i.ps1; & $env:TEMP\i.ps1"
# =====================================================================
param(
    [string]$Dest = "N:\MY AGENTS\ULTRON",
    [string]$Repo = "https://github.com/mirzaadin-crypto/Brahma-Ai-Evo.git"
)

$ErrorActionPreference = "Stop"
function Log($m){ Write-Host $m -ForegroundColor Cyan }

Write-Host "==============================================" -ForegroundColor Yellow
Write-Host "  ULTRON INSTALLER  ->  $Dest" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Yellow

# 1. Destination
if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Force -Path $Dest | Out-Null }
Set-Location $Dest

# 2. Get the app (git if available, else ZIP — no prerequisites)
if (-not (Test-Path (Join-Path $Dest "main.py"))) {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Log "Downloading ULTRON source (git)..."
        if (Test-Path (Join-Path $Dest ".git")) { git -C $Dest pull } else { git clone $Repo $Dest }
    } else {
        Log "git not found - downloading ZIP..."
        $zip = "$env:TEMP\brahma.zip"
        Invoke-WebRequest "https://github.com/mirzaadin-crypto/Brahma-Ai-Evo/archive/refs/heads/main.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive $zip -DestinationPath $Dest -Force
        $inner = Get-ChildItem $Dest -Directory | Where-Object { $_.Name -like 'Brahma-Ai-Evo*' } | Select-Object -First 1
        if ($inner) { Get-ChildItem $inner.FullName -Force | Move-Item -Destination $Dest -Force; Remove-Item $inner.FullName -Recurse -Force }
    }
} else { Log "Source already present, updating..."; git -C $Dest pull 2>$null }

# 3. Python (auto-install if missing)
$Python = $null
if (Get-Command py -ErrorAction SilentlyContinue) { $Python = "py" }
elseif (Get-Command python -ErrorAction SilentlyContinue) { $Python = "python" }
if (-not $Python) {
    Log "Python not found. Installing Python 3.11.8 (silent)..."
    $pi = "$env:TEMP\python_installer.exe"
    Invoke-WebRequest "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe" -OutFile $pi
    Start-Process $pi -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $Python = "python"
}
Log "Python: $Python"

# 4. venv + deps
$VP = "$Dest\.venv\Scripts\python.exe"
if (-not (Test-Path $VP)) { Log "Creating virtual environment..."; & $Python -m venv .venv }
Log "Installing dependencies (a few minutes)..."
& $VP -m pip install --upgrade pip setuptools wheel
& $VP -m pip install -r requirements.txt
Log "Installing browser engine..."
& $VP -m playwright install

# 5. Seed identity + MO golden rules + memory
$DataDir = Join-Path $env:LOCALAPPDATA "BrahmaAI"
New-Item -ItemType Directory -Force -Path "$DataDir\config" | Out-Null
New-Item -ItemType Directory -Force -Path "$DataDir\memory" | Out-Null
if (Test-Path "$Dest\mo_golden_rules.json") { Copy-Item "$Dest\mo_golden_rules.json" "$DataDir\config\learned_rules.json" -Force }
if (-not (Test-Path "$DataDir\memory\MEMORY.md")) { "date | agent | change | why | next" | Out-File "$DataDir\memory\MEMORY.md" -Encoding utf8 }

# 5b. Fetch ULTRON extras (bridge, autostart, docs) from the control repo
$Base = "https://raw.githubusercontent.com/mirzaadin-crypto/awesome-best-open-source-ai-agents-2026/cline/t22a7p34/install-ultron"
New-Item -ItemType Directory -Force -Path "$Dest\install-ultron" | Out-Null
foreach ($f in @("ultron_telegram_bridge.py","install_boot_autostart.ps1","start_telegram_bridge.bat","TELEGRAM_SETUP.md")) {
    try { Invoke-WebRequest "$Base/$f" -OutFile "$Dest\install-ultron\$f" -UseBasicParsing; Log "  + $f" } catch { Write-Host "  ! could not fetch $f" -ForegroundColor Yellow }
}

# 6. Regression gate
Log "Running regression gate..."
& $VP -m compileall -q "$Dest"
if ($LASTEXITCODE -ne 0) { throw "REGRESSION GATE FAILED. ULTRON not installed." }

# 7. Desktop shortcut + launch
$lnk = Join-Path ([Environment]::GetFolderPath("Desktop")) "ULTRON.lnk"
$ws = New-Object -ComObject WScript.Shell
$s = $ws.CreateShortcut($lnk)
$s.TargetPath = $VP; $s.Arguments = "main.py --startup"; $s.WorkingDirectory = $Dest; $s.Save()

# 7b. If a bot token is configured, enable boot auto-start now
if ([Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN","User")) {
    try {
        & "$Dest\install-ultron\install_boot_autostart.ps1" -Dest $Dest
        Log "Telegram bridge auto-start enabled."
    } catch { Write-Host "  ! autostart setup skipped: $_" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "  Desktop shortcut created: ULTRON" -ForegroundColor Green
Write-Host "  Launching now..." -ForegroundColor Yellow
Start-Process $VP -ArgumentList "main.py --startup" -WorkingDirectory $Dest
Write-Host "  Memory : $DataDir\memory\long_term.json"
Write-Host "  Rules  : $DataDir\config\learned_rules.json"
Write-Host "  (First run: add your Gemini API key in Settings)" -ForegroundColor Yellow
