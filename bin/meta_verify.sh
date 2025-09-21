#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
G="${GOOGLE_SITE_VERIFICATION:-}"; B="${BING_SITE_VERIFICATION:-}"
[[ -z "$G$B" ]] && { echo "ℹ️ no verification tokens set"; exit 0; }
for f in $(git ls-files '*.html'); do
  [[ -n "$G" ]] && rg -q 'name="google-site-verification"' "$f" || \
    perl -0777 -pe "s#</head>#<meta name=\"google-site-verification\" content=\"$G\">\n</head>#i" -i "$f"
  [[ -n "$B" ]] && rg -q 'name="msvalidate.01"' "$f" || \
    perl -0777 -pe "s#</head>#<meta name=\"msvalidate.01\" content=\"$B\">\n</head>#i" -i "$f"
done
echo "✅ site-verification metas injected (if tokens present)"
