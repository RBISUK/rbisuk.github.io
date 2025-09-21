#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mapfile -t ORIGS < <(rg -No 'https://[^/"]+' --glob '*.html' | sort -u || true)
[[ ${#ORIGS[@]} -eq 0 ]] && { echo "ℹ️ no external origins found"; exit 0; }
for f in $(git ls-files '*.html'); do
  for o in "${ORIGS[@]}"; do
    rg -q "rel=\"preconnect\" href=\"$o\"" "$f" && continue
    perl -0777 -pe "s#</head>#<link rel=\"preconnect\" href=\"$o\" crossorigin>\n</head>#i" -i "$f"
  done
done
echo "✅ preconnect hints added (deduped)"
