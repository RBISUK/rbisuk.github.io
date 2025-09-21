#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p reports
OUT="reports/page_check.csv"
echo "file,title,has_meta_description,has_canonical,h1_count,has_og_basic" > "$OUT"

mapfile -t pages < <(git ls-files '*.html' ':!reports/**' ':!assets/**' ':!node_modules/**')

for f in "${pages[@]}"; do
  title=$(grep -oPi '(?<=<title>).*?(?=</title>)' "$f" | head -n1 | tr -d '\n' | sed 's/,/ /g')
  md=$(grep -qi '<meta[^>]+name="description"' "$f" && echo yes || echo no)
  can=$(grep -qi '<link[^>]+rel="canonical"' "$f" && echo yes || echo no)
  h1c=$(grep -oi '<h1[^>]*>' "$f" | wc -l | tr -d ' ')
  og=$(grep -qi '<meta[^>]+property="og:title"' "$f" && grep -qi '<meta[^>]+property="og:description"' "$f" && echo yes || echo no)
  echo "$f,${title:-},$md,$can,$h1c,$og" >> "$OUT"
done
echo "📄 wrote $OUT"
