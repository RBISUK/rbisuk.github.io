#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
echo "Page|img src|has alt?" > reports/alt_audit.csv
for f in $(git ls-files '*.html'); do
  perl -0777 -ne 'while (m/<img([^>]+)>/gi){ $a=$1; ($src)=$a=~m/src="([^"]+)"/i; $has=($a=~m/\balt=/i)?"yes":"NO"; print "'$f'|$src|$has\n"; }' "$f" >> reports/alt_audit.csv
done
echo "✅ reports/alt_audit.csv"
