# Deploy OSmOS tools to your PC
param(
    [string]$Dir = "$env:USERPROFILE\osmos",
    [string]$Agent = "VISKO"
)
$ErrorActionPreference = "Stop"
$Base = "https://raw.githubusercontent.com/mirzaadin-crypto/awesome-best-open-source-ai-agents-2026/cline/t22a7p34"

New-Item -ItemType Directory -Force -Path $Dir | Out-Null
Write-Host "deploying to $Dir" -ForegroundColor Cyan

$files = @(
    "memory/mem.py",
    "memory/mem.cmd",
    "memory/CLINE_GLOBAL_RULES.md",
    "install-ultron/osmos_remote.py",
    "install-ultron/start_osmos_remote.bat"
)
foreach ($f in $files) {
    $name = Split-Path $f -Leaf
    $out  = Join-Path $Dir $name
    $ok = $false
    for ($i = 1; $i -le 3; $i++) {
        try { iwr ("$Base/$f?cb=" + (Get-Random)) -UseBasicParsing -OutFile $out; $ok = $true; break }
        catch { Start-Sleep -Seconds 3 }
    }
    if (-not $ok) {
        # CDN-lag fallback: GitHub API (base64), never served stale
        try {
            $api = "https://api.github.com/repos/mirzaadin-crypto/awesome-best-open-source-ai-agents-2026/contents/$f?ref=cline/t22a7p34"
            $j = Invoke-RestMethod $api -Headers @{ "User-Agent" = "osmos" }
            [IO.File]::WriteAllBytes($out, [Convert]::FromBase64String(($j.content -replace "`n|`r", "")))
            $ok = $true
        } catch {}
    }
    if ($ok) { Write-Host "  + $name" -ForegroundColor Green } else { Write-Host "  ! $name failed" -ForegroundColor Yellow }
}

# put the folder on PATH so `mem` works anywhere
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$Dir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$Dir", "User")
    Write-Host "  + added $Dir to PATH (open a new terminal)" -ForegroundColor Green
}
$env:Path += ";$Dir"

Write-Host ""
Write-Host "DEPLOYED." -ForegroundColor Cyan
Write-Host "  memory :  mem add \"note\" --agent $Agent   /   mem search \"topic\""
Write-Host "  remote :  start_osmos_remote.bat $Agent   (needs $($Agent.ToUpper())_TELEGRAM_TOKEN)"
Write-Host "  rules  :  paste $Dir\CLINE_GLOBAL_RULES.md into Cline -> Rules -> Global"
mem stats
