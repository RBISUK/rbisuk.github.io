#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p reports
echo "file,script_id,valid_json" > reports/jsonld_audit.csv
for f in $(git ls-files '*.html'); do
  # split on </script>, keep only ld+json blocks, capture id + body
  awk 'BEGIN{RS="</script>";FS="\n"} /type="application\/ld\+json"/{print}' "$f" | \
  awk 'match($0, /<script[^>]*id="([^"]*)".*?>(.*)$/s, a){print a[1] "|||" a[2]}' | \
  while IFS='|||' read -r sid body; do
    if printf '%s' "$body" | python3 -c 'import sys,json; json.loads(sys.stdin.read())' 2>/dev/null; then
      echo "$f,$sid,yes" >> reports/jsonld_audit.csv
    else
      echo "$f,$sid,NO"  >> reports/jsonld_audit.csv
    fi
  done
done
echo "✅ reports/jsonld_audit.csv"
