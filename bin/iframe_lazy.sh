#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's/<iframe(?![^>]*\bloading=)([^>]*?)>/<iframe loading="lazy" decoding="async"\1>/ig' -i "$f"
done
echo "✅ iframes set to loading=lazy"
