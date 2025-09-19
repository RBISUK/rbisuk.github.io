#!/usr/bin/env bash
set -euo pipefail
echo "🔎 Scanning copy for risky claims…"

# Only scan tracked files to avoid node_modules, build outputs, etc.
FILES=$(git ls-files | grep -v '^scripts/promise_guard.sh$' || true)
if [ -z "${FILES}" ]; then
  echo "ℹ️ No tracked files to scan. Skipping."
  exit 0
fi

# Patterns to block (regex). Keep precise; no weasel words.
PATTERNS=(
  "guarantee( |s|d)?\s*#?1"        # “guarantee #1” / “guarantees 1”
  "always at the top"              # absolute ranking claim
  "we (will|can) (win|guarantee) your case"
  "100%\s*(success|guarantee)"
)

FAIL=0
for pat in "${PATTERNS[@]}"; do
  # --line-number, --with-filename
  if grep -nE -I --color=never -- "$pat" $FILES >/dev/null; then
    echo "❌ Found risky phrase matching: /$pat/"
    grep -nE -I --color=never -- "$pat" $FILES || true
    FAIL=1
  fi
done

if [ $FAIL -eq 1 ]; then
  cat <<'TIP'
⚠ Suggested safer phrasing:
- “continuous optimisation” instead of “always at the top”
- “audit-ready evidence” instead of “guaranteed win”
- “targeted visibility improvements” instead of “#1 guarantee”
TIP
  exit 1
fi

echo "✅ Promise scan passed."
