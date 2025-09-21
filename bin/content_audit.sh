#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ts=$(date -u +%Y%m%dT%H%M%SZ)
out="audit/content-audit-${ts}.csv"
mkdir -p audit

echo "file,words,h1,h2,img,img_no_alt,links,title_len,desc_len,has_canonical,has_og,has_twitter,has_skip" > "$out"

for f in $(git ls-files '*.html' | sort); do
  b=$(tr -d '\n' < "$f")
  words=$(echo "$b" | sed 's/<script[^>]*>.*<\/script>//Ig;s/<style[^>]*>.*<\/style>//Ig' | sed 's/<[^>]*>/ /g' | tr -s ' ' | wc -w | awk '{print $1}')
  h1=$(grep -oi '<h1[^>]*>' "$f" | wc -l | awk '{print $1}')
  h2=$(grep -oi '<h2[^>]*>' "$f" | wc -l | awk '{print $1}')
  img=$(grep -oi '<img[^>]*>' "$f" | wc -l | awk '{print $1}')
  img_no_alt=$(grep -oi '<img[^>]*>' "$f" | grep -vi 'alt=' | wc -l | awk '{print $1}')
  links=$(grep -oi '<a [^>]*href=' "$f" | wc -l | awk '{print $1}')
  title_len=$(sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$f" | head -n1 | wc -m)
  desc_len=$(sed -n 's:.*<meta[^>]*name="description"[^>]*content="\([^"]*\)".*:\1:pI' "$f" | head -n1 | wc -m)
  has_canonical=$(grep -qi 'rel="canonical"' "$f" && echo yes || echo no)
  has_og=$(grep -qi 'property="og:title"' "$f" && echo yes || echo no)
  has_twitter=$(grep -qi 'twitter:card' "$f" && echo yes || echo no)
  has_skip=$(grep -qi 'id="skip-to-content"' "$f" && echo yes || echo no)

  echo "$f,$words,$h1,$h2,$img,$img_no_alt,$links,$title_len,$desc_len,$has_canonical,$has_og,$has_twitter,$has_skip" >> "$out"
done

echo "📊 Wrote $out"
echo "⚠️ Potential issues:"
awk -F, 'NR>1 && ($2<250 || $3!=1 || $6>0 || $9<50 || $10=="no" || $11=="no" || $12=="no" || $13=="no"){print}' "$out" | column -t -s,
