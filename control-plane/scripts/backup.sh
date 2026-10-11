#!/usr/bin/env bash
# Versioned private backup of the control plane to MO's own GitHub account.
# Run this on YOUR machine (uses YOUR gh auth). Sandbox can't create repos.
set -euo pipefail
REPO="${1:-mo-control-plane}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"

[ -d .git ] || git init -q
git add -A
git commit -q -m "backup $(date -u +%Y-%m-%dT%H:%M:%SZ)" || echo "nothing to commit"

if ! gh repo view "$REPO" >/dev/null 2>&1; then
  echo "creating private repo: $REPO"
  gh repo create "$REPO" --private --source=. --remote=origin --push
else
  git remote get-url origin >/dev/null 2>&1 || gh repo set-default "$REPO"
  git push -u origin HEAD
fi
echo "backed up to $(gh repo view "$REPO" --json url -q .url)"
