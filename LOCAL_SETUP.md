# How to run VISKO locally (on your laptop)

**"Me" is Cline.** Cloud Cline = no hands. Local Cline = hands.
Same agent, same rules, same memory → feels like the same "me".

---

## Option A — VS Code (recommended; you already have VS Code)

1. Install the extension:
```powershell
code --install-extension saoudrizwan.claude-dev
```
   (verified: Cline, **5.6M installs**)

2. Open VS Code → click the **Cline** icon in the sidebar → **Sign in**
   (use the **same account** you use here).

3. Open the folder you want me to work in:
   `File → Open Folder → N:\MY AGENTS\ULTRON` (or the repo).

4. Give me the laws (one time):
   VS Code → Cline → **Settings → Rules → Global** → paste `LAWBOOK.md`.

5. Done. Now I can run the **terminal**, edit files, use **Desktop Commander**, your **global skills**, everything.

---

## Option B — CLI (no IDE)

```powershell
npm install -g cline
cd N:\MY AGENTS\ULTRON
cline
```
Verified: `cline` npm **v3.0.71** — "Autonomous coding agent CLI".
Same agent, directly in your terminal.

---

## Option C — Keep both
- **Cloud (here):** planning, research, big thinking (no PC needed).
- **Local (there):** execution — terminal, installs, deploys.

They share the same **LAWBOOK + memory**, so they behave identically.

---

## Prerequisites
- **Node.js 20+**: `winget install OpenJS.NodeJS.LTS`
- VS Code (for Option A)

## After local install — give it a brain
```powershell
mem search "osmos"     # it reads the shared past
mem add "now running locally" --agent VISKO
```

## Why this is the whole answer
| | Cloud agent | Local agent |
|---|---|---|
| Terminal | ❌ | ✅ |
| Your files | ❌ | ✅ |
| Desktop Commander / skills | ❌ | ✅ |
| Same rules + memory | ✅ | ✅ |
