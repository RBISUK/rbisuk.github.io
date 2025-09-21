// RBIS PWA (lite)
const PRECACHE = [ { "url": "/index.html", "revision": "w5cmId6E/KVuMT+srBHc/G48kT1WxHxfArxravGQ208=" },{ "url": "/about.html", "revision": "VXx3X6f3MKi65kDyJLytKBhXhTh9yR5ed9m3nw0Dqd4=" },{ "url": "/products.html", "revision": "VwGeWG0m5yins+5JMSm/FELPrwmf/IiUR2HG80d4o4I=" },{ "url": "/reports.html", "revision": "bJZukUYRI4GjVL60OJBVJeXWg+ib1silAMOnMzyNKHw=" },{ "url": "/websites.html", "revision": "+n36ZekVWwogNA13UIvj0/m7LiryeckqNiYpM3s3/C4=" },{ "url": "/contact.html", "revision": "uaKQdsFAK62ocy8mpGHZOXedk2ce6bNsVPsCdQYMtes=" },{ "url": "/privacy.html", "revision": "j3Hvwrj8gfuUi/sUIZkSrHm3ASzVHQdOtC5JuDIk2E4=" },{ "url": "/assets/rbis.css", "revision": "CR03ja46MRdMYgnWjWANBc5JQSPuZ8UcHZdUv11RVGY=" },{ "url": "/assets/logo.svg", "revision": "BECGpMTTEJq7McUln+hpMVbSRyeSWdx3Hr2qgdkwuTA=" },{ "url": "/manifest.json", "revision": "5UToVeIlGUL8y1FBTSd+HkMDqeAoM0fJ9Q9uB5gBxWs=" },{ "url": "/assets/icons/apple-touch-icon.png", "revision": "QQQE+s5BawczpnO6s6OgOkBUI2o674OG3MKIIZS56sY=" },{ "url": "/assets/icons/android-chrome-192x192.png", "revision": "E6lsI8r2c69qxlkEhSHdLDAyl8N7xwdOLPbrN2J2gb8=" },{ "url": "/assets/icons/android-chrome-512x512.png", "revision": "M9OJ2IBZUf8MAxwGJYUHr2YWjQ8qD1d2G70JCRKwRUU=" },{ "url": "/offline.html", "revision": "Vc7nGT50Zbtbak8CsxZ5K2qqF7DxejALcMNyLWlZhiw=" } ];
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
