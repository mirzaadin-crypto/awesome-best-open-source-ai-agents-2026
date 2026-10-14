# INVESTIGATION REPORT — VISKO

## 1. The 404 error
**Cause:** CDN lag. You ran the download seconds after I pushed; `raw.githubusercontent.com` served a stale/missing entry.
**Proof:** all URLs now return **200** (`memory/mem.py`, `memory/mem.cmd`, `memory/README.md`).
**Fix applied:** DEPLOY.ps1 now retries (3×) and falls back to the GitHub API (never cached the same way).

## 2. `L:\MOZAK\nssm-2.24.zip` — what is here
I downloaded the **exact** `nssm-2.24.zip` (351,793 bytes, 39 files) and read it:

| Item | Detail |
|---|---|
| **Name** | NSSM — "The Non-Sucking Service Manager" |
| **Version** | 2.24, dated 2014-08-31 |
| **What it does** | Starts **any** app as a Windows **NT service**; auto-restarts on failure; GUI + CLI |
| **Binaries** | `win32/nssm.exe` (294 KB) · `win64/nssm.exe` (331 KB) |
| **Also** | `README.txt`, `ChangeLog.txt`, full C++ source in `src/` |

**Why it matters to us:** NSSM is exactly how we make OSmOS Remote + memory **always-on** — install the bridge as a service → it survives reboots, restarts on crash → **the Telegram channel stays open 24/7**. Your zip is the right tool already on the drive.

## 3. Why I can't drive your laptop (missing skills?)
**Not a missing skill — a missing *location*.**
- I run in a **cloud sandbox** (`/app` = "cline-core, Hub WebSocket server for Cline cloud sandbox").
- Your **global skills folder is on your PC**. My sandbox has **no skills folder, no MCP config, no Desktop Commander** (verified by full-filesystem scan).
- A **cloud** agent has no hands. A **local** agent does.

**The fix (choose one):**
1. `npm install -g cline` → `cline` → local agent, terminal + your skills + Desktop Commander all work.
2. VS Code → install Cline extension (`saoudrizwan.claude-dev`) → local.
3. Keep the cloud agent for planning; run the **local** one for execution.

## 4. Mnemos / Mnemosyne memory
**Not found on this machine** — only our chat mentions it. So it lived on your **laptop**, as you said.

**Best open-source match (verified):** `mnemosyne-oss/mnemosyne` — **3,417⭐**, MIT
- *"Zero-cloud AI memory that works everywhere. SQLite-backed. One pure-Python dependency."*
- PyPI: `mnemosyne-memory` · Python 3.10+ · **MCP-ready** · no external services
- Other candidates: `MnemosyneOS/mnemosyne` (37⭐, 31 MCP tools), `28naem-del/mnemosyne` (150⭐), `polymedia/mnemos` (MCP-native, repo now 404)

**This is almost certainly your "Mnemos"** — zero-cloud + SQLite + pip install + MCP matches "worked great on this laptop".

## 5. How Mnemosyne pairs with mem0
They solve the **same** problem differently — so **pick one as the brain, don't run both**:

| | Mnemosyne | mem0 |
|---|---|---|
| Stars | 3,417 | **67,193** |
| Storage | SQLite (local) | vector DB (local or cloud) |
| Cloud | **none** | optional (needs API key for LLM extraction) |
| Deps | one pure-Python dep | heavier |
| MCP | ready | yes |
| Best for | **local, private, zero-cost** | managed/production scale |

**Recommendation (single brain, per Article 8):**
- Start with **Mnemosyne** (local, no keys, matches your laptop).
- Keep our `mem.py` as the **rules/log spine** (append-only law + gate) — it is not a duplicate: it stores *decisions/laws*, not semantic recall.
- Only move to **mem0** if you later need cloud/scale — it can **read the same SQLite** via an adapter. Never run both writers at once (Article 8).
