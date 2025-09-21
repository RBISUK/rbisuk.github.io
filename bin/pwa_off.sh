#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
rm -f sw.js
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's#\s*<script id="sw-register">.*?</script>##is' -i "$f"
done
# gentle unregister on home page once
if ! rg -q 'id="sw-unregister-once"' index.html 2>/dev/null; then
  perl -0777 -pe 's#</body>#<script id="sw-unregister-once">if("serviceWorker"in navigator){navigator.serviceWorker.getRegistrations().then(rs=>rs.forEach(r=>r.unregister()));}</script></body>#i' -i index.html 2>/dev/null || true
fi
echo "✅ PWA off"
