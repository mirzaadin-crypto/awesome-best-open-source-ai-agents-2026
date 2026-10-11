# =====================================================================
#  ULTRON Telegram Bridge — auto-start at boot/logon
#  Creates a Windows Scheduled Task (no window, restart on failure).
#  Run once:  powershell -NoProfile -ExecutionPolicy Bypass -File .\install_boot_autostart.ps1
# =====================================================================
param(
    [string]$Dest = "N:\MY AGENTS\ULTRON"
)
$ErrorActionPreference = "Stop"
$TaskName = "ULTRON Telegram Bridge"

$vp = "$Dest\.venv\Scripts\pythonw.exe"
if (-not (Test-Path $vp)) { $vp = (Get-Command pythonw.exe -ErrorAction SilentlyContinue).Source }
if (-not $vp) { throw "pythonw.exe not found. Run INSTALL_ULTRON.ps1 first." }

$bridge = "$Dest\install-ultron\ultron_telegram_bridge.py"
if (-not (Test-Path $bridge)) { throw "Bridge not found at $bridge" }

if (-not [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN","User")) {
    Write-Host "WARNING: TELEGRAM_BOT_TOKEN not set for your user. The bot will fail to start." -ForegroundColor Yellow
}

$action  = New-ScheduledTaskAction -Execute $vp -Argument "`"$bridge`"" -WorkingDirectory $Dest
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
             -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Start-ScheduledTask -TaskName $TaskName

Write-Host ""
Write-Host "  ✅ Auto-start installed: $TaskName" -ForegroundColor Green
Write-Host "     Runs at every logon, restarts on failure, no window." -ForegroundColor Green
Write-Host "     Stop : Stop-ScheduledTask -TaskName '$TaskName'"
Write-Host "     Remove: Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false"
