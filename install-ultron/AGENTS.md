# ULTRON — Golden Rules (v1)

> Every agent (and every ULTRON skill) reads this FIRST. One source of truth.
> Owner: MO. Enforcement: automatic, not optional.

## 0. Prime directive
Ship. Every action must move a real product closer to *done*.

## 1. Read before act
Read `AGENTS.md` + `MEMORY.md` before any task. If it isn't written down, it doesn't exist.

## 2. Memory is mandatory
- Before: read memory (`%LOCALAPPDATA%\BrahmaAI\memory\long_term.json`).
- After: append `date | agent | change | why | next`.
- No entry = the task did not happen.

## 3. Never delete another agent's work
Append and extend. Removing/rewriting requires an explicit `DECISION:` line in memory.

## 4. Regression gate
No change lands without passing checks (`python -m compileall` + tests). Fail = never merge, never deploy. No exceptions.

## 5. Forbidden
Force-push, history rewrite, committing to default branch, new framework when an existing one covers it, silent scope creep.

## 6. Escalate, don't freelance
Ambiguous → stop, write the question under `OPEN:` in memory.

## 7. Uniform output
Every agent signs work: `agent: <name>`.
