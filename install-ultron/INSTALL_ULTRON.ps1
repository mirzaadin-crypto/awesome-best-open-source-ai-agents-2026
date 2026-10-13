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
# fix broken temp drive (e.g. missing M:\) before anything builds
$tmpFix = Join-Path $env:LOCALAPPDATA "Temp"
New-Item -ItemType Directory -Force -Path $tmpFix | Out-Null
$env:TEMP = $tmpFix; $env:TMP = $tmpFix
function Log($m){ Write-Host $m -ForegroundColor Cyan }

Write-Host "==============================================" -ForegroundColor Yellow
Write-Host "  ULTRON INSTALLER  ->  $Dest" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Yellow

# 1. Destination
if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Force -Path $Dest | Out-Null }
Set-Location $Dest

# 2. Get the app — clone to TEMP then copy in (works even if $Dest already has files)
if (-not (Test-Path (Join-Path $Dest "main.py"))) {
    $tmp = Join-Path $env:TEMP "ultron_src"
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Log "Downloading ULTRON source (git)..."
        git clone $Repo $tmp
    } else {
        Log "git not found - downloading ZIP..."
        $zip = Join-Path $env:TEMP "brahma.zip"
        Invoke-WebRequest "https://github.com/mirzaadin-crypto/Brahma-Ai-Evo/archive/refs/heads/main.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive $zip -DestinationPath $tmp -Force
        $inner = Get-ChildItem $tmp -Directory | Select-Object -First 1
        if ($inner) { Get-ChildItem $inner.FullName -Force | Move-Item -Destination $tmp -Force; Remove-Item $inner.FullName -Recurse -Force }
    }
    Log "Copying source into $Dest ..."
    Get-ChildItem $tmp -Force | Copy-Item -Destination $Dest -Recurse -Force
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Log "Source already present."
    if (Test-Path (Join-Path $Dest ".git")) { git -C $Dest pull 2>$null }
}

# 2b. Speed: drop .git (kills startup update check)
Remove-Item "$Dest\.git" -Recurse -Force -ErrorAction SilentlyContinue

# 3. Python - REQUIRE 3.11/3.12 (3.13/3.14 lack wheels for pyaudio etc.)
$Python = $null; $PyArgs = @()
if (Get-Command py -ErrorAction SilentlyContinue) {
    foreach ($v in @("-3.11","-3.12")) { if (py $v --version 2>$null) { $Python="py"; $PyArgs=@($v); break } }
}
if (-not $Python) {
    Log "Installing Python 3.11.9 (silent)..."
    $pi = "$env:TEMP\py311.exe"
    Invoke-WebRequest "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" -OutFile $pi
    Start-Process $pi -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0" -Wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $Python = "py"; $PyArgs = @("-3.11")
}
Log "Python: $Python $($PyArgs -join ' ')"

# 4. venv + deps
$VP = "$Dest\.venv\Scripts\python.exe"
if (-not (Test-Path $VP)) { Log "Creating virtual environment..."; & $Python @PyArgs -m venv .venv }
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
foreach ($f in @("agent_telegram_bridge.py","install_boot_autostart.ps1","start_osmos_fast.bat","TELEGRAM_SETUP.md")) {
    try { Invoke-WebRequest "$Base/$f" -OutFile "$Dest\install-ultron\$f" -UseBasicParsing; Log "  + $f" } catch { Write-Host "  ! could not fetch $f" -ForegroundColor Yellow }
}

# 6. Regression gate
Log "Running regression gate..."
& $VP -m compileall -q "$Dest"
if ($LASTEXITCODE -ne 0) { throw "REGRESSION GATE FAILED. ULTRON not installed." }

# 7. Desktop shortcut + launch
$lnk = Join-Path ([Environment]::GetFolderPath("Desktop")) "OSmOS.lnk"
$ws = New-Object -ComObject WScript.Shell
$s = $ws.CreateShortcut($lnk)
try { Invoke-WebRequest "$Base/ultron.ico" -OutFile "$Dest\ultron.ico" -UseBasicParsing } catch {}
$s.TargetPath = "$Dest\start_osmos_fast.bat"; $s.WorkingDirectory = $Dest
if (Test-Path "$Dest\ultron.ico") { $s.IconLocation = "$Dest\ultron.ico,0" }
$s.Description = "OSmOS"; $s.Save()

# 7b. If a bot token is configured, enable boot auto-start now
if ([Environment]::GetEnvironmentVariable("ULTRON_TELEGRAM_TOKEN","User")) {
    try {
        & "$Dest\install-ultron\install_boot_autostart.ps1" -Agent ULTRON -Dest $Dest
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
