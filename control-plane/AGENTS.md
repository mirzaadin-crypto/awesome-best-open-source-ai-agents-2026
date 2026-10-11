# AGENTS.md — MO Universal Rules (v1)

> Applies to **every** agent, in **every** repo, on **every** domain.
> Read this FIRST. If it isn't written down, it doesn't exist.
> One file. One truth. No exceptions.

## 0. RULE #1 — NEVER ASSUME. ACT ONLY IN FULL CERTAINTY.
- No assumption, ever. If it is not verified, it is not true.
- Verify across **≥2 independent sources** before any consequential action.
- State facts as `VERIFIED:` (source) or `ASSUMED:` (not allowed to act on).
- If certainty is missing → **stop and ask**. Never guess, never fill gaps silently.
- "Assume makes an ASS of U and ME."

## 0b. Prime directive
**Ship.** Every action must move a named product closer to *done*. If it doesn't, don't do it.

## 1. Read before act
Read `AGENTS.md` + `MEMORY.md` before any task.

## 2. Memory is mandatory
- Before: read memory.
- After: append `date | agent | change | why | next`.
- No entry = the task did not happen.

## 3. Never delete another agent's work
Append and extend. Removal/rewrite requires an explicit `DECISION:` line in memory.

## 4. Regression gate
No change lands without passing the gate (compile + tests). Fail = never merge, never deploy. No exceptions.

## 5. Forbidden
Force-push · history rewrite · commit to default branch · new tool when an existing one covers it · silent scope creep.

## 6. Escalate, don't freelance
Ambiguous → stop, write under `OPEN:` in memory.

## 7. Uniform output
Every agent signs: `agent: <name>`. Every task names its domain (see `DOMAINS.md`).

## 8. One domain, one owner
Each of the 29 domains has exactly ONE owning agent and ONE definition of done. No shared ownership.

---
v1 — frozen by orchestrator. Changes require a `DECISION:` line in `MEMORY.md`.
