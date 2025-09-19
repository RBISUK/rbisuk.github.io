/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    return [
      // hdr subdomain: / -> /hdr
      {
        source: '/',
        has: [{ type: 'host', value: 'hdr.rbisintelligence.com' }],
        destination: '/hdr',
      },
      // hdr subdomain: /apply -> /hdr/intake
      {
        source: '/apply',
        has: [{ type: 'host', value: 'hdr.rbisintelligence.com' }],
        destination: '/hdr/intake',
      },
    ];
  },
  async redirects() {
    return [
      // global: /intake -> /hdr/intake
      { source: '/intake', destination: '/hdr/intake', permanent: true },
    ];
  },
};

module.exports = nextConfig;
