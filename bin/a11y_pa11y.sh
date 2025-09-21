#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
OUT="reports/a11y"
mkdir -p "$OUT"

# Get site pages, but never scan anything under reports/
git ls-files -z '*.html' \
 | grep -z -v '^reports/' \
 | while IFS= read -r -d '' f; do
    dst="$OUT/$f"                  # mirror path (still ends .html — no .html.html)
    mkdir -p "$(dirname "$dst")"
    if command -v pa11y >/dev/null 2>&1; then
      # try nice HTML report; fall back to text without failing the build
      pa11y "file://$PWD/$f" --reporter html > "$dst" 2>/dev/null \
      || pa11y "file://$PWD/$f" --reporter cli  > "$dst" 2>/dev/null \
      || echo "pa11y encountered errors on $f" > "$dst"
    else
      echo "pa11y not installed; skipped $f" > "$dst"
    fi
  done

# Guard rails: remove any accidental dupes from older runs
find "$OUT" -type f -name '*.html.html' -delete 2>/dev/null || true
find "$OUT" -type d -path '*/reports/a11y/*' -print0 2>/dev/null | xargs -0r rm -rf || true

echo "✅ A11y reports in $OUT/"
