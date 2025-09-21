#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
echo "file,og:image,exists" > reports/og_audit.csv
for f in $(git ls-files '*.html'); do
  img=$(grep -Eio 'property="og:image"[^>]*content="[^"]+' "$f" | sed -E 's/.*content="([^"]+)".*/\1/' | head -n1 || true)
  if [[ -n "${img:-}" ]]; then
    path="${img#https://www.rbisintelligence.com}"; path="${path#/}"
    [[ -f "$path" ]] && ok="yes" || ok="NO"
    echo "$f,$img,$ok" >> reports/og_audit.csv
  else
    echo "$f, , " >> reports/og_audit.csv
  fi
done
echo "✅ reports/og_audit.csv"
