#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
VAL='accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()'
for f in $(git ls-files '*.html'); do
  if rg -q 'http-equiv="Permissions-Policy"' "$f"; then
    perl -0777 -pe "s#<meta http-equiv=\"Permissions-Policy\" content=\"[^\"]*\">#<meta http-equiv=\"Permissions-Policy\" content=\"$VAL\">#i" -i "$f"
  else
    perl -0777 -pe "s#</head>#<meta http-equiv=\"Permissions-Policy\" content=\"$VAL\">\n</head>#i" -i "$f"
  fi
done
echo "✅ Permissions-Policy injected"
