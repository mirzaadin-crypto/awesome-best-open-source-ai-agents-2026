# MO Control Plane

One rules file + one memory + one gate = regression becomes mechanically impossible.

## Files
- `AGENTS.md` — **v1 universal rules.** Every agent reads this first.
- `MEMORY.md` — append-only shared brain. One line per task.
- `DOMAINS.md` — your 29 properties × 5 production tracks.
- `scripts/gate.sh` — regression gate (run before anything lands).
- `scripts/audio.sh` — any text → MP3 (listen instead of read).
- `scripts/backup.sh` — 1-command private versioned backup to your GitHub.
- `scripts/tts.py` — the TTS engine (no deps).

## Daily loop (30 seconds)
1. `bash scripts/gate.sh <repo>` → must print **GATE PASSED**.
2. Append one line to `MEMORY.md`.
3. `bash scripts/backup.sh` → versioned private backup.

## The rule that ends your regression
> **Nothing lands without passing the gate. Fail = never merge. No exceptions.**

## Setup on your PC
```powershell
git clone <this branch> ; cd control-plane
bash scripts/gate.sh .          # dogfood the gate
bash scripts/backup.sh          # private backup to YOUR account
```
