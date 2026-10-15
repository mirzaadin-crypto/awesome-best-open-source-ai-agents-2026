# =====================================================================
#  OSmOS "BOTH" setup:  (1) Mnemosyne local brain  (2) Telegram 24/7 service (NSSM)
#  Run elevated:  powershell -ExecutionPolicy Bypass -File setup_both.ps1
# =====================================================================
param(
    [string]$Tools   = "$env:USERPROFILE\osmos",
    [string]$NssmZip = "L:\MOZAK\nssm-2.24.zip",
    [string]$Agent   = "VISKO"
)
$ErrorActionPreference = "Continue"
$Base = "https://raw.githubusercontent.com/mirzaadin-crypto/awesome-best-open-source-ai-agents-2026/cline/t22a7p34"
$AgentUp = $Agent.ToUpper()
$TokenVar = "${AgentUp}_TELEGRAM_TOKEN"

function Get-File($rel, $out) {
    for ($i=1; $i -le 3; $i++) {
        try { iwr ("$Base/$rel?cb=" + (Get-Random)) -UseBasicParsing -OutFile $out; return $true } catch { Start-Sleep 3 }
    }
    try {
        $api = "https://api.github.com/repos/mirzaadin-crypto/awesome-best-open-source-ai-agents-2026/contents/$rel?ref=cline/t22a7p34"
        $j = Invoke-RestMethod $api -Headers @{ "User-Agent" = "osmos" }
        [IO.File]::WriteAllBytes($out, [Convert]::FromBase64String(($j.content -replace "`n|`r", "")))
        return $true
    } catch { return $false }
}

New-Item -ItemType Directory -Force -Path $Tools | Out-Null
Write-Host "== OSmOS BOTH setup ==  tools: $Tools" -ForegroundColor Cyan

# ---------- python ----------
$py = $null
if (Get-Command py -EA SilentlyContinue) { foreach ($v in @("-3.11","-3.12")) { if (py $v --version 2>$null) { $py = "py $v"; break } } }
if (-not $py) { if (Get-Command python -EA SilentlyContinue) { $py = "python" } }
if (-not $py) { Write-Host "! No Python found. Install 3.11 first." -ForegroundColor Red; return }
Write-Host "python: $py" -ForegroundColor Green
$p = $py -split ' '; $pyExe = $p[0]; $pyArgs = @(); if ($p.Count -gt 1) { $pyArgs = $p[1..($p.Count-1)] }

# ---------- 1) Mnemosyne local brain ----------
Write-Host "`n[1/2] Mnemosyne (local brain)..." -ForegroundColor Cyan
& $pyExe @pyArgs -m pip install --upgrade "mnemosyne-memory[all]"
& $pyExe @pyArgs -c "from mnemosyne import remember, recall; remember('OSmOS Mnemosyne brain online'); print('  mnemosyne OK')"

# register Mnemosyne MCP for Cline / VS Code / Cursor if those configs exist
$mcpPaths = @(
  "$env:APPDATA\Code\User\mcp.json",
  "$env:APPDATA\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json",
  "$env:USERPROFILE\.cursor\mcp.json"
)
foreach ($mp in $mcpPaths) {
    if (Test-Path $mp) {
        Copy-Item $mp "$mp.bak-$(Get-Date -Format yyyyMMdd-HHmmss)" -Force
        try {
            $cfg = Get-Content $mp -Raw | ConvertFrom-Json
            $key = if ($cfg.PSObject.Properties.Name -contains "mcpServers") { "mcpServers" } elseif ($cfg.PSObject.Properties.Name -contains "servers") { "servers" } else { "mcpServers" }
            if (-not ($cfg.PSObject.Properties.Name -contains $key)) { $cfg | Add-Member -NotePropertyName $key -NotePropertyValue ([pscustomobject]@{}) }
            $cfg.$key | Add-Member -NotePropertyName "mnemosyne" -NotePropertyValue ([pscustomobject]@{ command = "mnemosyne"; args = @("mcp") }) -Force
            $cfg | ConvertTo-Json -Depth 10 | Set-Content $mp -Encoding utf8
            Write-Host "  + mnemosyne MCP -> $mp" -ForegroundColor Green
        } catch { Write-Host "  ! mcp update failed: $mp" -ForegroundColor Yellow }
    }
}
