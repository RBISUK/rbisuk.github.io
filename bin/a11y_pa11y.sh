#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v npx >/dev/null || { echo "ℹ️ skipping a11y (Node/npm not available)"; exit 0; }
mkdir -p reports/a11y
PORT=8090
python3 -m http.server "$PORT" >/dev/null 2>&1 & srv=$!; trap 'kill $srv 2>/dev/null || true' EXIT
BASE="http://127.0.0.1:$PORT"
while read -r f; do
  out="reports/a11y/$f"
  mkdir -p "$(dirname "$out")"
  npx --yes pa11y "$BASE/$f" --reporter html > "$out" 2>/dev/null || true
  echo "♿ a11y -> $out"
done < <(git ls-files '*.html')
echo "✅ A11y reports in reports/a11y/"
