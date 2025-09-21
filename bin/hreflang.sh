#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"

for f in $(git ls-files '*.html'); do
  url="$ORIGIN/${f}"
  if ! grep -qi 'rel="alternate" hreflang="en-GB"' "$f"; then
    sed -i "0,/<head[^>]*>/{s//&\n  <link rel=\"alternate\" hreflang=\"en-GB\" href=\"${url//\//\\/}\">/}" "$f"
  fi
  if ! grep -qi 'rel="alternate" hreflang="x-default"' "$f"; then
    sed -i "0,/<head[^>]*>/{s//&\n  <link rel=\"alternate\" hreflang=\"x-default\" href=\"${url//\//\\/}\">/}" "$f"
  fi
done
echo "✅ hreflang injected"
