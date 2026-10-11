#!/usr/bin/env bash
# MO Regression Gate — run before ANY change lands.
# Usage: scripts/gate.sh [path-to-repo]
set -uo pipefail
REPO="${1:-.}"
fail=0
echo "== MO Regression Gate =="
echo "repo: $REPO"

# 1. Python syntax
if find "$REPO" -name '*.py' -not -path '*/.venv/*' -not -path '*/node_modules/*' | grep -q .; then
  echo "-- python compile --"
  python3 -m compileall -q "$REPO" || { echo "FAIL: python compile"; fail=1; }
fi

# 2. JS/TS
if [ -f "$REPO/package.json" ]; then
  echo "-- node --"
  ( cd "$REPO" && npm test --silent ) || { echo "FAIL: npm test"; fail=1; }
fi

# 3. Tests
if [ -d "$REPO/tests" ] && [ -f "$REPO/pytest.ini" -o -f "$REPO/pyproject.toml" ]; then
  echo "-- pytest --"
  ( cd "$REPO" && python3 -m pytest -q ) || { echo "FAIL: pytest"; fail=1; }
fi

# 4. Broken markdown links (light)
echo "-- link scan --"
grep -rEho 'https?://[^ )"]+' "$REPO"/*.md 2>/dev/null | sort -u | while read -r u; do
  code=$(curl -s -o /dev/null -w '%{http_code}' -I --max-time 8 "$u" || echo 000)
  [ "$code" = "000" ] && echo "  warn: unreachable $u"
done

if [ "$fail" -ne 0 ]; then
  echo "== GATE FAILED — DO NOT MERGE =="
  exit 1
fi
echo "== GATE PASSED =="
