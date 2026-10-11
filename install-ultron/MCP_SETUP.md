# MCP setup — Android + Tailscale

**Chosen (verified best on GitHub):**
| Need | Server | Package |
|---|---|---|
| Android/iOS control | `mobile-next/mobile-mcp` | `npx -y @mobilenext/mobile-mcp@latest` |
| Tailscale control | `HexSleeves/tailscale-mcp` | `npx -y @hexsleeves/tailscale-mcp-server` |

## Run it
```powershell
powershell -ExecutionPolicy Bypass -File setup_mcp.ps1            # install + clean
powershell -ExecutionPolicy Bypass -File setup_mcp.ps1 -ReportOnly # just show what's where
```

It will:
1. Find every MCP config on the PC (VS Code, Cursor, Claude, Gemini).
2. **Back up** each before touching it (`*.bak-<timestamp>`).
3. Remove **old** Android/Tailscale MCP entries.
4. Install the 2 chosen servers.

## Requirements
- **Node.js 20+** (for npx)
- **Android platform-tools / adb** for mobile-mcp
- **Tailscale** installed + logged in for tailscale-mcp

## Then
VS Code → **MCP Servers** → trust + start.
