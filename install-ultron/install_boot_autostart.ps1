# =====================================================================
#  Agent Telegram Bridge — auto-start at boot/logon (per agent)
#  Usage:
#    .\install_boot_autostart.ps1 -Agent VISKO
#    .\install_boot_autostart.ps1 -Agent ULTRON
# =====================================================================
param(
    [string]$Agent = "ULTRON",
    [string]$Dest  = "N:\MY AGENTS\ULTRON"
)
$ErrorActionPreference = "Stop"
$AgentUp  = $Agent.ToUpper()
$TaskName = "$AgentUp Telegram Bridge"
$TokenVar = "${AgentUp}_TELEGRAM_TOKEN"

$vp = "$Dest\.venv\Scripts\pythonw.exe"
if (-not (Test-Path $vp)) { $vp = (Get-Command pythonw.exe -ErrorAction SilentlyContinue).Source }
if (-not $vp) { throw "pythonw.exe not found. Run INSTALL_ULTRON.ps1 first." }

$bridge = "$Dest\install-ultron\agent_telegram_bridge.py"
if (-not (Test-Path $bridge)) { throw "Bridge not found at $bridge" }

if (-not [Environment]::GetEnvironmentVariable($TokenVar, "User")) {
    Write-Host "WARNING: $TokenVar not set for your user. $AgentUp bot will not start." -ForegroundColor Yellow
}

$action  = New-ScheduledTaskAction -Execute $vp -Argument "`"$bridge`" --agent $AgentUp" -WorkingDirectory $Dest
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
             -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Start-ScheduledTask -TaskName $TaskName

Write-Host ""
Write-Host "  Auto-start installed: $TaskName" -ForegroundColor Green
Write-Host "     Token var: $TokenVar" -ForegroundColor Green
Write-Host "     Stop   : Stop-ScheduledTask -TaskName '$TaskName'"
Write-Host "     Remove : Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false"
