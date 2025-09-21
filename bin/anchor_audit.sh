#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p reports
echo "file,href,id_present" > reports/anchors.csv
for f in $(git ls-files '*.html'); do
  ids=$(grep -Eo 'id="[^"]+"' "$f" | sed 's/id="//;s/"$//' | sort -u)
  while IFS= read -r href; do
    tgt="${href#\#}"
    present=$(echo "$ids" | grep -xq "$tgt" && echo yes || echo NO)
    echo "$f,$href,$present"
  done < <(grep -Eo 'href="#[^"]+"' "$f" | sed 's/href="//;s/"$//')
done >> reports/anchors.csv
echo "✅ reports/anchors.csv"
