#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
feedlink='<link rel="alternate" type="application/atom+xml" href="/reports.xml">'
mask='<link rel="mask-icon" href="/assets/icons/safari-pinned-tab.svg" color="#111111">'
theme='<meta name="theme-color" content="#111111"><meta name="color-scheme" content="dark light">'
for f in $(git ls-files '*.html'); do
  # theme-color
  if ! grep -qi 'name="theme-color"' "$f"; then
    tmp=$(mktemp); awk -v T="$theme" '/<\/head>/{print T RS $0; next} {print}' "$f" > "$tmp" && mv "$tmp" "$f"
  fi
  # mask-icon
  if [[ -f assets/icons/safari-pinned-tab.svg ]] && ! grep -qi 'rel="mask-icon"' "$f"; then
    tmp=$(mktemp); awk -v M="$mask" '/<\/head>/{print M RS $0; next} {print}' "$f" > "$tmp" && mv "$tmp" "$f"
  fi
  # feed link
  if [[ -f reports.xml ]] && ! grep -qi 'type="application/atom\+xml"' "$f"; then
    tmp=$(mktemp); awk -v L="$feedlink" '/<\/head>/{print L RS $0; next} {print}' "$f" > "$tmp" && mv "$tmp" "$f"
  fi
  # og:image:alt from <title>
  title=$(sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$f" | head -n1); [[ -z "$title" ]] && title="RBIS"
  if ! grep -qi 'property="og:image:alt"' "$f"; then
    ALT="<meta property=\"og:image:alt\" content=\"${title}\">"
    tmp=$(mktemp); awk -v ALT="$ALT" '/<\/head>/{print ALT RS $0; next} {print}' "$f" > "$tmp" && mv "$tmp" "$f"
  fi
  echo "✅ head hygiene -> $f"
done
