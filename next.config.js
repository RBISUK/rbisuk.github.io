/** @type {import(next).NextConfig} */
const nextConfig = {
  async rewrites() {
    return [
      // HDR subdomain root → /hdr
      {
        source: "/",
        has: [{ type: "host", value: "hdr.rbisintelligence.com" }],
        destination: "/hdr",
      },
      // HDR subdomain /apply → /hdr/intake
      {
        source: "/apply",
        has: [{ type: "host", value: "hdr.rbisintelligence.com" }],
        destination: "/hdr/intake",
      },
    ];
  },
  async redirects() {
    return [
      // Global: /intake → /hdr/intake
      { source: "/intake", destination: "/hdr/intake", permanent: true },
    ];
  },
};
module.exports = nextConfig;
