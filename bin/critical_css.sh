#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v npx >/dev/null || { echo "ℹ️ skipping critical CSS (no Node)"; exit 0; }
npx --yes critical --version >/dev/null 2>&1 || npx --yes npm@9.2.0 -c "npm i -D critical" >/dev/null 2>&1 || true
PORT=8086
python3 -m http.server "$PORT" >/dev/null 2>&1 & srv=$!; trap 'kill $srv 2>/dev/null || true' EXIT
BASE="http://127.0.0.1:$PORT"
for f in index.html products.html reports.html websites.html 2>/dev/null; do
  [[ -f "$f" ]] || continue
  npx --yes critical "$BASE/$f" --minify --inline --extract --timeout 60000 --width 1300 --height 900 \
    --rebase --inlineImages false --path . -o "$f" >/dev/null || true
  echo "⚙️  critical CSS inlined -> $f"
done
echo "✅ critical CSS pass complete"
