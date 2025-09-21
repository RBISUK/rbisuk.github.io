#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
MODE="${CSP_ENFORCE:-0}"
HDR='Content-Security-Policy-Report-Only'
[[ "$MODE" = "1" ]] && HDR='Content-Security-Policy'
POLICY="default-src 'self'; img-src 'self' data: https:; script-src 'self' https://cdn.tailwindcss.com 'unsafe-inline'; style-src 'self' 'unsafe-inline'; connect-src 'self' https://plausible.io https://analytics.eu.org; base-uri 'self'; frame-ancestors 'self'; form-action 'self'"
for f in $(git ls-files '*.html'); do
  # replace if exists; else insert once
  if rg -q 'http-equiv="Content-Security-Policy' "$f"; then
    perl -0777 -pe "s#<meta http-equiv=\"Content-Security-Policy[^\"]*\" content=\"[^\"]*\">#<meta http-equiv=\"$HDR\" content=\"$POLICY\">#i" -i "$f"
  elif rg -q 'http-equiv="Content-Security-Policy-Report-Only' "$f"; then
    perl -0777 -pe "s#<meta http-equiv=\"Content-Security-Policy-Report-Only\" content=\"[^\"]*\">#<meta http-equiv=\"$HDR\" content=\"$POLICY\">#i" -i "$f"
  else
    perl -0777 -pe "s#</head>#<meta http-equiv=\"$HDR\" content=\"$POLICY\">\n</head>#i" -i "$f"
  fi
done
echo "✅ CSP ($HDR) injected"
