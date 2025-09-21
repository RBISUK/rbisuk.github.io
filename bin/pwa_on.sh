#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"; ORIGIN="${ORIGIN%/}"
# 1) offline page
[[ -f offline.html ]] || cat > offline.html <<'HTML'
<!doctype html><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Offline • RBIS</title>
<link rel="stylesheet" href="/assets/rbis.css">
<main class="pad">
  <h1>You're offline</h1>
  <p>We’ll auto-retry when you’re back online.</p>
  <p><a href="/">Go home</a></p>
</main>
HTML

# 2) precache list (top pages + critical assets if present)
mklist(){ for f in "$@"; do [[ -f "$f" ]] && echo "$f"; done; }
mapfile -t FILES < <(mklist index.html about.html products.html reports.html websites.html contact.html privacy.html \
  assets/rbis.css assets/logo.svg manifest.json \
  assets/icons/apple-touch-icon.png assets/icons/android-chrome-192x192.png assets/icons/android-chrome-512x512.png \
  offline.html)

PRECACHE="$(printf '%s\n' "${FILES[@]}" | awk 'NF' | while read -r f; do
  h="$(openssl dgst -sha256 -binary "$f" | openssl base64 -A 2>/dev/null || echo 0)"
  printf '{ "url": "/%s", "revision": "%s" },' "$f" "$h"
done | sed 's/,$//')"

# 3) service worker (cache-first for assets, network-first for pages, offline fallback)
cat > sw.js <<SW
// RBIS PWA (lite)
const PRECACHE = [ $PRECACHE ];
const CACHE = 'rbis-v1';
self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(PRECACHE.map(x=>x.url))));
  self.skipWaiting();
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k)))));
  self.clients.claim();
});
self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);
  if (e.request.mode === 'navigate') {
    e.respondWith(fetch(e.request).catch(()=>caches.match('/offline.html')));
    return;
  }
  if (PRECACHE.some(x=>x.url===url.pathname)) {
    e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request).then(res=>{
      const copy = res.clone();
      caches.open(CACHE).then(c=>c.put(e.request, copy));
      return res;
    })));
    return;
  }
});
SW

# 4) register snippet (once)
for f in $(git ls-files '*.html'); do
  rg -q 'id="sw-register"' "$f" && continue
  perl -0777 -pe 's#</body>#<script id="sw-register">if("serviceWorker"in navigator){navigator.serviceWorker.register("/sw.js",{scope:"/"}).catch(()=>{});}</script></body>#i' -i "$f"
done
echo "✅ PWA on (sw.js + offline + registration)"
