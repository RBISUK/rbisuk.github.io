#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v node >/dev/null || { echo "ℹ️ Node not found; skipping"; exit 0; }
pages=(index.html about.html products.html websites.html)
for f in "${pages[@]}"; do
  [[ -f "$f" ]] || continue
  npx --yes critical "$f" --inline --minify --extract --width 1300 --height 900 || true
done
echo "✅ critical CSS attempted"
