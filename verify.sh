#!/usr/bin/env bash
set -euo pipefail
fail=0
# internal .html only (skip http/mailto/tel/#), exclude drafts
hits=$(find . -type f -name '*.html' ! -path './drafts/*' -exec perl -0777 -ne 'print "$ARGV\n" if m/href="(?!https?:\/\/|mailto:|tel:|#)[^"]+\.html"/i' {} + | sort -u)
if [ -n "$hits" ]; then echo "❌ internal .html hrefs remain:"; echo "$hits"; fail=1; else echo "✅ no internal .html hrefs"; fi
# canonicals on all folder index pages (not drafts)
miss=$(for f in $(git ls-files '**/index.html' | grep -v '^drafts/'); do grep -qi 'rel="canonical"' "$f" || echo "$f"; done)
if [ -n "$miss" ]; then echo "❌ missing canonical:"; echo "$miss"; fail=1; else echo "✅ canonicals present"; fi
exit $fail
