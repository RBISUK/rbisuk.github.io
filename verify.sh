#!/usr/bin/env bash
set -euo pipefail
base="https://www.rbisintelligence.com"

# key routes should be 200
for p in / /about/ /reports/ /veridex/ /contact/ ; do
  printf "=== %s ===\n" "$p"
  curl -sI "$base$p" | awk 'BEGIN{RS=""} /HTTP\/|last-modified|etag/'
done

# icons present?
curl -sI "$base/favicon.ico" | awk 'BEGIN{RS=""} /HTTP\/|content-type|content-length/'
curl -sI "$base/icons/favicon-192.png" | awk 'BEGIN{RS=""} /HTTP\/|content-type|content-length/'

# OG block on home
curl -s "$base/" | sed -n '/RBIS:OG START/,/RBIS:OG END/p' | sed -n '1,15p'

# no .html hrefs in public pages
if grep -RIl --exclude-dir=".git" --exclude-dir="drafts" -E 'href="[^"]+\.html"' . ; then
  echo "⚠️  .html links remain above — replace with folder routes"
else
  echo "👍 No .html links in public pages"
fi
