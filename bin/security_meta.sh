#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
CSP="default-src 'self'; img-src 'self' data: https:; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; font-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'"
for f in $(git ls-files '*.html'); do
  grep -qi 'name="referrer"' "$f" || sed -i '0,/<head[^>]*>/{s//&\n  <meta name="referrer" content="no-referrer-when-downgrade">/}' "$f"
  grep -qi 'http-equiv="Content-Security-Policy-Report-Only"' "$f" || \
    sed -i "0,/<head[^>]*>/{s//&\n  <meta http-equiv=\"Content-Security-Policy-Report-Only\" content=\"${CSP//\//\\/}\">/}" "$f"
done
echo "✅ security meta (report-only CSP + referrer) injected"
