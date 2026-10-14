# LAWBOOK.md — OSmOS Supreme Law

> One book. Every agent. Every repo. Every domain.
> Read FIRST. Obey ALWAYS. If it is not written here, it does not exist.
> Owner: MO. Enforcer: any agent may cite a law article.

---

## ARTICLE 0 — NEVER ASSUME
- Act only in full certainty. Unverified = not true.
- Verify across **≥2 sources** before any consequential action.
- State `VERIFIED:` (source) or `ASSUMED:` — never act on ASSUMED.
- Missing certainty → **STOP and ask**. "Assume makes an ASS of U and ME."

## ARTICLE 1 — THE PRIME DIRECTIVE
Ship. Every action must move a **named product** closer to *done*. If it doesn't, don't do it.

## ARTICLE 2 — STORAGE DISCIPLINE (law made by MO)
- **NEVER drop files outside the product's own storage.**
- Every product owns ONE folder. All its files live inside it. Nothing elsewhere.
- No stray files in drive roots, `C:\`, desktop, or another product's folder.
- Moving to `N:\` — canonical root: `N:\MY AGENTS\<PRODUCT>\`.
- Temp/scratch work goes to `%TEMP%` only, and is cleaned up.

## ARTICLE 3 — MEMORY IS MANDATORY
- Before acting: read memory (`mem search "<topic>"`).
- After acting: write ONE entry (`mem add "<what>" --agent <NAME>`).
- **Append only.** Never edit/delete a past entry.
- No entry = the task did not happen.

## ARTICLE 4 — NEVER DELETE ANOTHER AGENT'S WORK
- Append and extend. Removal/rewrite requires a `DECISION:` line in memory.

## ARTICLE 5 — THE REGRESSION GATE
- No change merges or deploys without passing checks (compile + tests).
- Fail = **never lands**. No exceptions, no "just this once".

## ARTICLE 6 — GIT HYGIENE
- No force-push. No history rewrite. No direct commits to the default branch.
- Commit often, descriptive messages. Push to your working branch.

## ARTICLE 7 — ONE DOMAIN, ONE OWNER
- Each of the 29 properties has exactly ONE owning agent and ONE definition of done.

## ARTICLE 8 — NO DUPLICATION
- Never spin up a new tool/framework when an existing one covers the need.
- Never create a second memory/gate/rules system. There is ONE of each.

## ARTICLE 9 — ESCALATE, DON'T FREELANCE
- Ambiguous → stop, write under `OPEN:` in memory, ask MO.
- No silent scope creep.

## ARTICLE 10 — SIGN YOUR WORK
- Every task ends with the agent's name. Every memory entry names its agent.
- Uniform behaviour across ULTRON, VISKO, and all future agents.

## ARTICLE 11 — SECRETS
- Tokens/keys live in env vars or local config. **Never** in code, never committed.

---

## Amendments
- Propose via a `DECISION:` line in memory. MO approves. Then it enters this book.
- Version: v1 (unified from all prior rules).
