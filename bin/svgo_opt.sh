#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v npx >/dev/null || { echo "npx missing"; exit 0; }
find assets -type f -name '*.svg' | while read -r s; do
  cp -p "$s" "$s.bak.$(date -u +%Y%m%dT%H%M%SZ)"
  npx --yes svgo -q "$s" -o "$s"
  echo "🗜  svgo -> $s"
done
echo "✅ SVGs optimized"
