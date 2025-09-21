#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
OUT="reports/a11y"
mkdir -p "$OUT"

# Only real site pages; skip generated stuff
mapfile -t PAGES < <(git ls-files '*.html' ':!reports/**' ':!assets/**' ':!node_modules/**' ':!**/reports/**' ':!**/assets/**')

for f in "${PAGES[@]}"; do
  dst="$OUT/$f"
  mkdir -p "$(dirname "$dst")"

  if command -v pa11y >/dev/null 2>&1; then
    pa11y "file://$PWD/$f" --reporter html > "$dst" 2>/dev/null || \
    pa11y "file://$PWD/$f" --reporter cli > "$dst" 2>/dev/null || \
    echo "pa11y encountered errors on $f" > "$dst"
  else
    # Minimal placeholder so CI always has an artifact
    awk 'BEGIN{t=0}/<title>/{t=1} END{print (t?"OK: title present":"WARN: no <title>")}' "$f" > "$dst"
  fi

  # Make sure the artifacts never get indexed
  if grep -qi '<head' "$dst"; then
    perl -0777 -pe 's#</head>#<meta name="robots" content="noindex,nofollow">\n</head>#i' -i "$dst" || true
  else
    sed -i '1i <!-- robots: noindex -->' "$dst" || true
  fi

  echo "♿ a11y -> $dst"
done

echo "✅ A11y reports in $OUT/"
