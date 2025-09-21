const CACHE_NAME = 'rbis-$(date -u +%Y%m%d)';
const PRECACHE_URLS = [
  '/',
  '/offline.html',
  '/404.html',
  '/about.html',
  '/assets/critical/404.html about.html careers.html contact.html cookies.html dashboard.html deep.html docs/hello.html embed/product.html hello.html index.html landing.enterprise.html landing.minimal.html landing.story.html offerings.html privacy.html products.html reports.html search.html sections/claim-fix-ai.html sections/custom-sites-&-seo-ai.html sections/nextusone-crm.html sections/omniassist.html sections/pact-ledger.html sections/rbis-dashboard.html sitemap.html solutions.html surfaces/dashboard.html surfaces/sections/claim-fix-ai.html surfaces/sections/custom-sites-&-seo-ai.html surfaces/sections/nextusone-crm.html surfaces/sections/omniassist.html surfaces/sections/pact-ledger.html surfaces/sections/rbis-dashboard.html terms.html trust.html trust/accessibility/statement.html trust/policies/cookies.html trust/policies/privacy.html trust/policies/retention.html trust/security/overview.html veridex-demo.html veridex.html websites.html .css',
  '/assets/icons/android-chrome-192x192.png',
  '/assets/icons/android-chrome-512x512.png',
  '/assets/icons/apple-touch-icon.png',
  '/assets/icons/favicon.ico',
  '/assets/icons/safari-pinned-tab.svg',
  '/assets/logo.svg',
  '/assets/og/404.png',
  '/assets/og/about.png',
  '/assets/og/careers.png',
  '/assets/og/contact.png',
  '/assets/og/cookies.png',
  '/assets/og/dashboard.png',
  '/assets/og/deep.png',
  '/assets/og/docs_hello.png',
  '/assets/og/embed_product.png',
  '/assets/og/hello.png',
  '/assets/og/index.png',
  '/assets/og/landing.enterprise.png',
  '/assets/og/landing.minimal.png',
  '/assets/og/landing.story.png',
  '/assets/og/offerings.png',
  '/assets/og/privacy.png',
  '/assets/og/products.png',
  '/assets/og/sections_claim-fix-ai.png',
  '/assets/og/sections_custom-sites-&-seo-ai.png',
  '/assets/og/sections_nextusone-crm.png',
  '/assets/og/sections_omniassist.png',
  '/assets/og/sections_pact-ledger.png',
  '/assets/og/sections_rbis-dashboard.png',
  '/assets/og/solutions.png',
  '/assets/og/surfaces_dashboard.png',
  '/assets/og/surfaces_sections_claim-fix-ai.png',
  '/assets/og/surfaces_sections_custom-sites-&-seo-ai.png',
  '/assets/og/surfaces_sections_nextusone-crm.png',
  '/assets/og/surfaces_sections_omniassist.png',
  '/assets/og/surfaces_sections_pact-ledger.png',
  '/assets/og/surfaces_sections_rbis-dashboard.png',
  '/assets/og/terms.png',
  '/assets/og/trust.png',
  '/assets/og/trust_accessibility_statement.png',
  '/assets/og/trust_policies_cookies.png',
  '/assets/og/trust_policies_privacy.png',
  '/assets/og/trust_policies_retention.png',
  '/assets/og/trust_security_overview.png',
  '/assets/og/veridex-demo.png',
  '/assets/og/veridex.png',
  '/assets/og/websites.png',
  '/assets/prices.json',
  '/assets/rbis.css',
  '/assets/rbis.js',
  '/assets/rbis.min.css',
  '/assets/rbis.nav.js',
  '/assets/report_details.json',
  '/assets/reports.js',
  '/careers.html',
  '/contact.html',
  '/cookies.html',
  '/dashboard.html',
  '/deep.html',
  '/docs/hello.html',
  '/embed/product.html',
  '/favicon.svg',
  '/hello.html',
  '/index.html',
  '/landing.enterprise.html',
  '/landing.minimal.html',
  '/landing.story.html',
  '/manifest.json',
  '/offerings.html',
  '/offline.html',
  '/privacy.html',
  '/products.html',
  '/rbis.products.json',
  '/reports.html',
  '/reports/a11y/404.html',
  '/reports/a11y/404.html.html',
  '/reports/a11y/about.html',
  '/reports/a11y/about.html.html',
  '/reports/a11y/careers.html',
  '/reports/a11y/careers.html.html',
  '/reports/a11y/contact.html',
  '/reports/a11y/contact.html.html',
  '/reports/a11y/cookies.html',
  '/reports/a11y/cookies.html.html',
  '/reports/a11y/dashboard.html',
  '/reports/a11y/dashboard.html.html',
  '/reports/a11y/deep.html',
  '/reports/a11y/deep.html.html',
  '/reports/a11y/docs/hello.html',
  '/reports/a11y/docs/hello.html.html',
  '/reports/a11y/embed/product.html',
  '/reports/a11y/embed/product.html.html',
  '/reports/a11y/hello.html',
  '/reports/a11y/hello.html.html',
  '/reports/a11y/index.html',
  '/reports/a11y/index.html.html',
  '/reports/a11y/landing.enterprise.html',
  '/reports/a11y/landing.enterprise.html.html',
  '/reports/a11y/landing.minimal.html',
  '/reports/a11y/landing.minimal.html.html',
  '/reports/a11y/landing.story.html',
  '/reports/a11y/landing.story.html.html',
  '/reports/a11y/offerings.html',
  '/reports/a11y/offerings.html.html',
  '/reports/a11y/privacy.html',
  '/reports/a11y/privacy.html.html',
  '/reports/a11y/products.html',
  '/reports/a11y/products.html.html',
  '/reports/a11y/reports.html',
  '/reports/a11y/reports.html.html',
  '/reports/a11y/search.html',
  '/reports/a11y/search.html.html',
  '/reports/a11y/sections/claim-fix-ai.html',
  '/reports/a11y/sections/claim-fix-ai.html.html',
  '/reports/a11y/sections/custom-sites-&-seo-ai.html',
  '/reports/a11y/sections/custom-sites-&-seo-ai.html.html',
  '/reports/a11y/sections/nextusone-crm.html',
  '/reports/a11y/sections/nextusone-crm.html.html',
  '/reports/a11y/sections/omniassist.html',
  '/reports/a11y/sections/omniassist.html.html',
  '/reports/a11y/sections/pact-ledger.html',
  '/reports/a11y/sections/pact-ledger.html.html',
  '/reports/a11y/sections/rbis-dashboard.html',
  '/reports/a11y/sections/rbis-dashboard.html.html',
  '/reports/a11y/sitemap.html',
  '/reports/a11y/sitemap.html.html',
  '/reports/a11y/solutions.html',
  '/reports/a11y/solutions.html.html',
  '/reports/a11y/surfaces/dashboard.html',
  '/reports/a11y/surfaces/dashboard.html.html',
  '/reports/a11y/surfaces/sections/claim-fix-ai.html',
  '/reports/a11y/surfaces/sections/claim-fix-ai.html.html',
  '/reports/a11y/surfaces/sections/custom-sites-&-seo-ai.html',
  '/reports/a11y/surfaces/sections/custom-sites-&-seo-ai.html.html',
  '/reports/a11y/surfaces/sections/nextusone-crm.html',
  '/reports/a11y/surfaces/sections/nextusone-crm.html.html',
  '/reports/a11y/surfaces/sections/omniassist.html',
  '/reports/a11y/surfaces/sections/omniassist.html.html',
  '/reports/a11y/surfaces/sections/pact-ledger.html',
  '/reports/a11y/surfaces/sections/pact-ledger.html.html',
  '/reports/a11y/surfaces/sections/rbis-dashboard.html',
  '/reports/a11y/surfaces/sections/rbis-dashboard.html.html',
  '/reports/a11y/terms.html',
  '/reports/a11y/terms.html.html',
  '/reports/a11y/trust.html',
  '/reports/a11y/trust.html.html',
  '/reports/a11y/trust/accessibility/statement.html',
  '/reports/a11y/trust/accessibility/statement.html.html',
  '/reports/a11y/trust/policies/cookies.html',
  '/reports/a11y/trust/policies/cookies.html.html',
  '/reports/a11y/trust/policies/privacy.html',
  '/reports/a11y/trust/policies/privacy.html.html',
  '/reports/a11y/trust/policies/retention.html',
  '/reports/a11y/trust/policies/retention.html.html',
  '/reports/a11y/trust/security/overview.html',
  '/reports/a11y/trust/security/overview.html.html',
  '/reports/a11y/veridex-demo.html',
  '/reports/a11y/veridex-demo.html.html',
  '/reports/a11y/veridex.html',
  '/reports/a11y/veridex.html.html',
  '/reports/a11y/websites.html',
  '/reports/a11y/websites.html.html',
  '/search.html',
  '/sections/claim-fix-ai.html',
  '/sections/custom-sites-&-seo-ai.html',
  '/sections/nextusone-crm.html',
  '/sections/omniassist.html',
  '/sections/pact-ledger.html',
  '/sections/rbis-dashboard.html',
  '/sitemap.html',
  '/solutions.html',
  '/style.css',
  '/surfaces/dashboard.html',
  '/surfaces/sections/claim-fix-ai.html',
  '/surfaces/sections/custom-sites-&-seo-ai.html',
  '/surfaces/sections/nextusone-crm.html',
  '/surfaces/sections/omniassist.html',
  '/surfaces/sections/pact-ledger.html',
  '/surfaces/sections/rbis-dashboard.html',
  '/sw.js',
  '/terms.html',
  '/trust.html',
  '/trust/accessibility/statement.html',
  '/trust/policies/cookies.html',
  '/trust/policies/privacy.html',
  '/trust/policies/retention.html',
  '/trust/security/overview.html',
  '/trust/status/current.json',
  '/trust/subprocessors/list.json',
  '/veridex-demo.html',
  '/veridex.html',
  '/version.json',
  '/websites.html',
];
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
