#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
rm -f sw.js offline.html || true
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's/<script>if\\("serviceWorker".*?<\/script>//si' -i "$f" || true
done
echo "✅ PWA removed"
