# =====================================================================
#  MO MCP setup — install best Android + Tailscale MCP, clean old ones
#  Run:  powershell -ExecutionPolicy Bypass -File setup_mcp.ps1
#        powershell -ExecutionPolicy Bypass -File setup_mcp.ps1 -ReportOnly
# =====================================================================
param(
    [switch]$ReportOnly
)
$ErrorActionPreference = "Stop"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Chosen (verified best) servers
$Best = @{
    "mobile-mcp"    = @{ command = "npx"; args = @("-y","@mobilenext/mobile-mcp@latest") }
    "tailscale-mcp" = @{ command = "npx"; args = @("-y","@hexsleeves/tailscale-mcp-server") }
}

# Common MCP config locations on Windows
$Candidates = @(
    "$env:APPDATA\Code\User\mcp.json",                       # VS Code (user)
    "$env:USERPROFILE\.vscode\mcp.json",
    "$env:USERPROFILE\.cursor\mcp.json",                     # Cursor (global)
    "$env:APPDATA\Claude\claude_desktop_config.json",        # Claude Desktop
    "$env:USERPROFILE\.claude.json",                         # Claude Code
    "$env:USERPROFILE\.gemini\config\mcp_config.json"        # Gemini/Antigravity
)

Write-Host "== Scanning for MCP configs ==" -ForegroundColor Cyan
$found = @()
foreach ($p in $Candidates) { if (Test-Path $p) { $found += $p; Write-Host "  found: $p" -ForegroundColor Green } }
if (-not $found) { Write-Host "  none found in common locations" -ForegroundColor Yellow }

# Deep-ish scan of the user profile for any mcp*.json / claude_desktop_config.json
Write-Host "== Deep scan (user profile) ==" -ForegroundColor Cyan
$deep = Get-ChildItem -Path $env:USERPROFILE -Recurse -Force -ErrorAction SilentlyContinue `
        -Include "mcp.json","*mcp*.json","claude_desktop_config.json" |
        Where-Object { $_.FullName -notmatch '\\node_modules\\' } |
        Select-Object -ExpandProperty FullName -Unique
$deep | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }

if ($ReportOnly) {
    Write-Host "`nReport-only mode. Nothing changed." -ForegroundColor Yellow
    return
}

function Update-Config($path) {
    Write-Host "`n-- updating $path" -ForegroundColor Cyan
    Copy-Item $path "$path.bak-$stamp" -Force
    Write-Host "   backup: $path.bak-$stamp"
    $raw = Get-Content $path -Raw
    try { $cfg = $raw | ConvertFrom-Json } catch { Write-Host "   ! invalid JSON, skipped" -ForegroundColor Yellow; return }

    $key = if ($cfg.PSObject.Properties.Name -contains "mcpServers") { "mcpServers" }
           elseif ($cfg.PSObject.Properties.Name -contains "servers") { "servers" }
           else { "mcpServers" }
    if (-not ($cfg.PSObject.Properties.Name -contains $key)) { $cfg | Add-Member -NotePropertyName $key -NotePropertyValue ([pscustomobject]@{}) }

    $servers = $cfg.$key
    $names = @($servers.PSObject.Properties.Name)

    # Remove OLD android/tailscale entries that are not our chosen ones
    foreach ($n in $names) {
        $ln = $n.ToLower()
        if (($ln -match 'android|mobile') -and ($n -ne "mobile-mcp")) {
            $servers.PSObject.Properties.Remove($n); Write-Host "   removed old: $n" -ForegroundColor Yellow
        }
        if (($ln -match 'tailscale') -and ($n -ne "tailscale-mcp")) {
            $servers.PSObject.Properties.Remove($n); Write-Host "   removed old: $n" -ForegroundColor Yellow
        }
    }
    # Add / overwrite best
    foreach ($name in $Best.Keys) {
        $servers | Add-Member -NotePropertyName $name -NotePropertyValue ([pscustomobject]$Best[$name]) -Force
        Write-Host "   set: $name" -ForegroundColor Green
    }
    $cfg | ConvertTo-Json -Depth 10 | Set-Content $path -Encoding utf8
}

foreach ($p in ($found + $deep | Select-Object -Unique)) {
    if (Test-Path $p) { Update-Config $p }
}

Write-Host "`n✅ MCP setup done. Backups saved as *.bak-$stamp" -ForegroundColor Green
Write-Host "   Open VS Code -> MCP Servers -> trust + start. Node.js 20+ required." -ForegroundColor Yellow
