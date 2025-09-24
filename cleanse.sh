#!/usr/bin/env sh
set -eu
STD='<div style="background:#FFFBEB;padding:8px;border-bottom:1px solid #FCD34D"><b>Disclosure:</b> RBIS is not a law firm and does not provide legal advice. We analyse only the evidence in front of our intelligence officers, objectively and without bias.</div>'
set -- *.html; [ -d articles ] && set -- "$@" articles/*.html
for f in "$@"; do
  [ -f "$f" ] || continue
  awk 'BEGIN{IGNORECASE=1} !/not a law firm/ {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  if ! grep -qi 'not a law firm' "$f"; then
    awk -v s="$STD" 'BEGIN{add=0} {print; if(!add && match(tolower($0),/<body[^>]*>/)){print s; add=1}}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
done
echo "cleanse done"
