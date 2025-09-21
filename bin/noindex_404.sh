#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
f="404.html"; [[ -f "$f" ]] || exit 0
grep -qi 'name="robots"' "$f" && sed -i 's/name="robots"[^>]*>/\<meta name="robots" content="noindex, nofollow">/I' "$f" || \
  awk '/<\/head>/{print "<meta name=\"robots\" content=\"noindex, nofollow\">" RS $0; next} {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
echo "✅ 404 noindex set"
