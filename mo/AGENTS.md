# AGENTS.md — MO Golden Rules (v0 draft)

> One file. Every agent reads this FIRST, before any action. This is the single source of truth for behaviour.
> Status: DRAFT — awaiting MO's 5 answers, then frozen as v1.

## 0. Prime directive
Ship. Every change must move the first product closer to *done*. If a task does not, do not do it.

## 1. Read-before-act
1. Read `AGENTS.md` (this file) and `MEMORY.md` before starting.
2. Never assume context. If it is not written down, it does not exist.

## 2. Memory is mandatory
- Before acting: read `MEMORY.md`.
- After acting: append one line — `date | agent | what changed | why | next`.
- No entry = the task did not happen.

## 3. Never delete other agents' work
- Append and extend. Do not rewrite or remove another agent's output without an explicit `DECISION:` line in `MEMORY.md`.
- Regression, not progress, is the default failure mode. Assume you are the one who will cause it, and guard against it.

## 4. Regression gate
- No change merges or deploys without passing tests/checks.
- Failing check = the change does not land. Ever. No exceptions, no "just this once".

## 5. Forbidden
- Force-push, rewriting history, committing to the default branch.
- Spinning up a new framework/tool when an existing one covers the need.
- Silent scope creep.

## 6. Escalate, don't freelance
- Ambiguous? Stop and ask. Write the question into `MEMORY.md` under `OPEN:`.

## 7. Uniform output
- Every agent signs its work: `agent: <name>`.

---
Change log: v0 (draft) — created by orchestrator.
