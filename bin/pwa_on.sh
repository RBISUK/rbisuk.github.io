#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
backup index.html
# offline fallback
cat > offline.html <<'HTML'
<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Offline • RBIS</title><link rel="stylesheet" href="/assets/rbis.css">
<main class="container"><h1>Offline</h1><p>You’re offline. Core pages and assets still work; refresh when back online.</p></main>
HTML
# service worker
cat > sw.js <<'JS'
const VERSION = 'rbis-v1';
const CORE = [
  '/', '/assets/rbis.css', '/assets/logo.svg', '/offline.html'
];
self.addEventListener('install', e=>{
  e.waitUntil(caches.open(VERSION).then(c=>c.addAll(CORE)));
});
self.addEventListener('activate', e=>{
  e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==VERSION).map(k=>caches.delete(k)))));
});
self.addEventListener('fetch', e=>{
  const u = new URL(e.request.url);
  if (u.origin === location.origin && (u.pathname.startsWith('/assets/') || u.pathname === '/' )) {
    e.respondWith(caches.match(e.request).then(r=> r || fetch(e.request).then(resp=>{
      const copy = resp.clone(); caches.open(VERSION).then(c=>c.put(e.request, copy)); return resp;
    })).catch(()=>caches.match('/offline.html')));
  }
});
JS
# register in pages
for f in $(git ls-files '*.html'); do
  grep -q 'navigator.serviceWorker' "$f" && continue
  awk '
    /<\/body>/ && !done {
      print "<script>if(\"serviceWorker\" in navigator){window.addEventListener(\"load\",()=>navigator.serviceWorker.register(\"/sw.js\").catch(()=>{}));}</script>";
      print; done=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ PWA register -> $f"
done
echo "✅ PWA enabled (sw.js + offline.html + registration)"
