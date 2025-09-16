import type { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
  const routes = [
    '', '/main', '/main/value',
    '/hdr', '/hdr/pricing', '/hdr/what-it-does', '/hdr/trust', '/hdr/value',
  ];
  const base = 'https://rbisuk.github.io';
  return routes.map((r) => ({
    url: `${base}${r}`,
    changeFrequency: 'weekly',
    priority: r ? 0.7 : 1,
  }));
}
