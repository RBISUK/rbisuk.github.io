#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"; ORIGIN="${ORIGIN%/}"

# A) offline page (only if missing)
if [[ ! -f offline.html ]]; then
  cat > offline.html <<'HTML'
<!doctype html><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Offline • RBIS</title>
<link rel="stylesheet" href="/assets/rbis.css">
<main style="min-height:60vh;display:grid;place-items:center;text-align:center">
  <div>
    <h1>You're offline</h1>
    <p>We’ll keep key pages available if your connection drops.</p>
    <p><a href="/" rel="home">← Back to RBIS</a></p>
  </div>
</main>
HTML
fi

# B) Build a versioned, deterministic pre-cache list (same-origin only)
mapfile -t FILES < <(
  git ls-files | grep -E '\.(html|css|js|png|jpe?g|webp|svg|ico|json|woff2?)$' \
  | sed -E 's#^#/#' | sort -u
)
# Always ensure root + offline are present
PRECACHE=("/" "/offline.html")
for p in "${FILES[@]}"; do
  # keep same-origin only
  case "$p" in
    http://*|https://*) continue;;
    *) PRECACHE+=("$p");;
  esac
done

# C) Write sw.js with cache version & strategies
V="rbis-\$(date -u +%Y%m%d)"
TMP="$(mktemp)"; {
  echo "const CACHE_NAME = '${V}';"
  echo "const PRECACHE_URLS = ["
  for u in "${PRECACHE[@]}"; do printf "  '%s',\n" "$u"; done
  echo "];"
  cat <<'JS'
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(PRECACHE_URLS))
  );
  self.skipWaiting();
});
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.map((k) => (k === CACHE_NAME ? null : caches.delete(k))))
    )
  );
  self.clients.claim();
});
const sameOrigin = (url) => self.location.origin === new URL(url, self.location).origin;

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  // HTML navigations: network-first with offline fallback
  if (req.headers.get('accept')?.includes('text/html')) {
    event.respondWith(
      (async () => {
        try {
          const net = await fetch(req, { cache: 'no-store' });
          // Optionally cache fresh HTML
          const cache = await caches.open(CACHE_NAME);
          cache.put(req, net.clone());
          return net;
        } catch {
          const cache = await caches.open(CACHE_NAME);
          return (await cache.match(req)) ||
                 (await cache.match('/offline.html')) ||
                 new Response('offline', { status: 503 });
        }
      })()
    );
    return;
  }

  // Static same-origin assets: cache-first
  if (sameOrigin(req.url)) {
    event.respondWith(
      caches.match(req).then((hit) => hit || fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(CACHE_NAME).then((c) => c.put(req, copy)).catch(()=>{});
        return res;
      }))
    );
  }
});
JS
} > "$TMP"
mv "$TMP" sw.js

# D) Safe registration snippet (dedup by id)
for f in $(git ls-files '*.html'); do
  if ! grep -q 'id="rbis-sw-reg"' "$f"; then
    perl -0777 -pe 's#</head>#<script id="rbis-sw-reg">if("serviceWorker" in navigator){window.addEventListener("load",()=>{navigator.serviceWorker.register("/sw.js");});}</script>\n</head>#i' -i "$f"
  fi
done

echo "✅ PWA on (sw.js + offline + safe registration)"
