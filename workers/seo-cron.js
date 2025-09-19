export default {
  async scheduled(event, env, ctx) {
    // Nightly sitemap ping
    ctx.waitUntil(fetch(`https://www.google.com/ping?sitemap=${encodeURIComponent(env.SITE_URL + '/sitemap.xml')}`).catch(()=>{}));
    ctx.waitUntil(fetch(`https://www.bing.com/ping?sitemap=${encodeURIComponent(env.SITE_URL + '/sitemap.xml')}`).catch(()=>{}));
  },
  async fetch() { return new Response("ok"); }
}
