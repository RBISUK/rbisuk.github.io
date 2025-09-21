#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's/<img(?![^>]*\bloading=)([^>]*?)>/sprintf("<img loading=\"lazy\" decoding=\"async\"%s>",$1)/eig' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "✅ loading=\"lazy\" + decoding=\"async\" added to <img>"
