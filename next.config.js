/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    return [
      // On HDR subdomain, "/" → "/hdr"
      {
        source: '/',
        has: [{ type: 'host', value: 'hdr.rbisintelligence.com' }],
        destination: '/hdr',
      },
      // On HDR subdomain, "/apply" → "/hdr/intake"
      {
        source: '/apply',
        has: [{ type: 'host', value: 'hdr.rbisintelligence.com' }],
        destination: '/hdr/intake',
      },
    ];
  },
  async redirects() {
    return [
      // Global: "/intake" → "/hdr/intake"
      {
        source: '/intake',
        destination: '/hdr/intake',
        permanent: true,
      },
    ];
  },
};

module.exports = nextConfig;
