#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
out="reports/meta_audit.csv"
echo "file,title_len,has_desc,desc_len,has_h1" > "$out"
for f in $(git ls-files '*.html'); do
  title=$(sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$f" | head -n1)
  tlen=${#title}
  desc=$(grep -Eio '<meta[^>]+name="description"[^>]+>' "$f" | sed -E 's/.*content="([^"]*)".*/\1/I' | head -n1)
  dlen=${#desc}
  h1=$(grep -Eio '<h1[^>]*>' "$f" | head -n1 || true)
  hasd="no"; [[ -n "${desc:-}" ]] && hasd="yes"
  hash1="no"; [[ -n "${h1:-}" ]] && hash1="yes"
  echo "$f,$tlen,$hasd,$dlen,$hash1" >> "$out"
done
echo "✅ $out"
