#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's#<head([^>]*)>#<head\1>\n<meta name="theme-color" media="(prefers-color-scheme: light)" content="#ffffff">\n<meta name="theme-color" media="(prefers-color-scheme: dark)" content="#0b0b0b">\n<meta name="format-detection" content="telephone=no">#i' -i "$f"
done
echo "🎨 theme-color + format-detection added"
