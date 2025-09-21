#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's/<script(?![^>]*\b(type|async|defer)\b)([^>]*\bsrc=)([^>]*?)>/<script defer$2$3>/gi' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "✅ non-critical external <script> tagged with defer"
