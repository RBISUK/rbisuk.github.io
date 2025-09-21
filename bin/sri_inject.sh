#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v curl >/dev/null && command -v openssl >/dev/null || { echo "ℹ️ curl/openssl missing; skipping SRI"; exit 0; }
is_versioned(){ [[ "$1" =~ @|v[0-9]|\.[0-9]+\.[0-9]+ ]]; }
for f in $(git ls-files '*.html'); do
  mapfile -t TAGS < <(rg -No '<(script|link)[^>]+(src|href)="https://[^"]+"' "$f" || true)
  [[ ${#TAGS[@]} -eq 0 ]] && continue
  for t in "${TAGS[@]}"; do
    url="$(grep -Eo 'https://[^"]+' <<<"$t")"
    is_versioned "$url" || { echo "↪︎ skip SRI (unversioned): $url"; continue; }
    sum="$(curl -fsSL "$url" | openssl dgst -sha384 -binary | openssl base64 -A)" || { echo "↪︎ skip SRI (fetch fail): $url"; continue; }
    if grep -q "$url" "$f"; then
      perl -0777 -pe "s#((?:script|link)[^>]+(?:src|href)=\"$url\"[^>]*)(?<!integrity=\"[^\"]+\")>#\\1 integrity=\"sha384-$sum\" crossorigin=\"anonymous\">#i" -i "$f"
    fi
  done
done
echo "✅ SRI injected where safe"
