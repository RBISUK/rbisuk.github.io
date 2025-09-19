import https from "https";
const SITE = process.env.SITE_URL || "https://your-domain.example";
const urls = [
  `https://www.google.com/ping?sitemap=${encodeURIComponent(SITE+'/sitemap.xml')}`,
  `https://www.bing.com/ping?sitemap=${encodeURIComponent(SITE+'/sitemap.xml')}`
];
function hit(u){ return new Promise(res=> https.get(u, () => res()).on('error',()=>res())); }
for (const u of urls) { await hit(u); }
console.log("Sitemap pinged:", urls.join(" | "));
