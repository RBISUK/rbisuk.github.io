#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
feedlink='<link rel="alternate" type="application/atom+xml" href="/reports.xml">'
mask='<link rel="mask-icon" href="/assets/icons/safari-pinned-tab.svg" color="#111111">'
theme='<meta name="theme-color" content="#111111"><meta name="color-scheme" content="dark light">'
for f in $(git ls-files '*.html'); do
  # ensure theme + color-scheme
  grep -qi 'name="theme-color"' "$f" || awk -v T="$theme" '/<\/head>/{print T RS $0; next} {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  # mask icon if present
  if [[ -f assets/icons/safari-pinned-tab.svg ]] && ! grep -qi 'rel="mask-icon"' "$f"; then
    awk -v M="$mask" '/<\/head>/{print M RS $0; next} {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
  # feed link if feed exists
  if [[ -f reports.xml ]] && ! grep -qi 'type="application/atom\+xml"' "$f"; then
    awk -v L="$feedlink" '/<\/head>/{print L RS $0; next} {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
  # og:image:alt based on <title>
  title=$(sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$f" | head -n1)
  [[ -z "$title" ]] && title="RBIS"
  grep -qi 'property="og:image:alt"' "$f" || awk -v ALT="<meta property=\"og:image:alt\" content=\"${title}\">" '/<\/head>/{print ALT RS $0; next} {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ head hygiene -> $f"
done
