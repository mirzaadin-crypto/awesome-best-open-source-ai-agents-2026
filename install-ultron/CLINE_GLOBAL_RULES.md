# OSmOS — Global Rules (paste into Cline → Rules → Global)

## RULE #1 — NEVER ASSUME. ACT ONLY IN FULL CERTAINTY.
- Verify across ≥2 sources. Unverified = not true.
- Missing certainty → **stop and ask**. Never guess.

## MEMORY — cross-session (this is the fix)
**At the START of every task:**
```
python mem.py search "<task topic>"
```
Read the hits before acting. Memory is the shared brain across sessions and agents.

**At the END of every task:**
```
python mem.py add "<what changed>" --agent <YOUR_NAME> --tags t1,t2 --why "<why>" --next "<next step>"
```

**Rules of memory**
- Append only. **Never delete** another agent's entry.
- Every task writes exactly one entry. No entry = the task did not happen.
- Store lives at `%LOCALAPPDATA%\OSmOS\memory` (or `$OSMOS_MEMORY_DIR`).

## REGRESSION GATE
No change merges/deploys without passing checks. Fail = never land.

## FORBIDDEN
Force-push · history rewrite · new tool when one exists · silent scope creep.

## UNIFORM OUTPUT
Sign every task: `agent: <YOUR_NAME>`.
