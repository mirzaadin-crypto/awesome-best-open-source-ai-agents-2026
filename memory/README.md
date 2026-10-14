# OSmOS Memory — cross-session, cross-agent

**Problem:** agents forget everything between sessions → regression.
**Fix:** one append-only memory every agent reads at start and writes at end.

## Use it
```powershell
python mem.py search "installer python"        # read memory (start of task)
python mem.py add "shipped X" --agent VISKO --tags install --why "blocker" --next "bump version"
python mem.py tail 20
python mem.py stats
python mem.py export        # writes MEMORY.md (human-readable)
python mem.py sync          # optional: git commit/sync the store
```

## Where it lives
- `$OSMOS_MEMORY_DIR` if set, else `%LOCALAPPDATA%\OSmOS\memory`
- Store: `memory.jsonl` (append-only) + `MEMORY.md` (readable)

## Why this ends regression
- **Cross-session:** survives restarts — nothing is forgotten.
- **Cross-agent:** ULTRON, VISKO, any agent reads the same brain.
- **Uniform:** the Global Rules force search-before / add-after.
- **Safe:** append-only; no agent can erase another's work.

## Make it automatic
Paste `CLINE_GLOBAL_RULES.md` into **Cline → Rules → Global**.
Then every agent, every session, obeys the same memory loop.

## No cloud, no API keys
Pure Python standard library. Works offline. Works on any machine.
