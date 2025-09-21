#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p logs
ts="$(date -u +%Y%m%dT%H%M%SZ)"

[[ -x bin/clean_html.sh ]] || { echo "❌ bin/clean_html.sh missing or not executable"; exit 1; }

# DRY_RUN=1 only prints targets
if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo "🔎 Dry-run targets:"
  git ls-files '*.html' | while read -r f; do echo "• $f"; done
  exit 0
fi

# Real sweep with logs
git ls-files '*.html' | while read -r f; do
  echo "➡️  $f"; bash -x bin/clean_html.sh "$f" 2>&1 | tee -a "logs/clean.$ts.log"
done

echo "✅ Sweep done. Staging diff:"
git add -A
git --no-pager diff --cached --stat || true
