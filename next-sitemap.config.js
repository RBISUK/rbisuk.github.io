/** @type {import('next-sitemap').IConfig} */
module.exports = {
  siteUrl: process.env.SITE_URL || 'https://your-domain.example',
  generateRobotsTxt: true,
  changefreq: 'daily',
  priority: 0.7,
  exclude: ['/api/*'],
  transform: async (config, path) => {
    return { loc: path, changefreq: 'daily', priority: path==='/hdr' ? 0.9 : 0.7, lastmod: new Date().toISOString() };
  }
}
