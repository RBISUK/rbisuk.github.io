#!/usr/bin/env sh
set -eu
STD='<div style="background:#FFFBEB;padding:8px;border-bottom:1px solid #FCD34D"><b>Disclosure:</b> RBIS is not a law firm and does not provide legal advice. We analyse only the evidence in front of our intelligence officers, objectively and without bias.</div>'
set -- *.html; [ -d articles ] && set -- "$@" articles/*.html
for f in "$@"; do
  [ -f "$f" ] || continue
  # 1) remove any existing disclosure lines (case-insensitive)
  awk 'BEGIN{IGNORECASE=1} /disclosure:.*not a law firm/{next} {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  # 2) add standard banner after <body> if not present
  grep -iq 'not a law firm' "$f" || awk -v s="$STD" 'BEGIN{done=0} /<body[^>]*>/ && !done{print; print s; done=1; next} {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "cleanse done"
