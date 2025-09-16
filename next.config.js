/** @type {import('next').NextConfig} */
const nextConfig = {
  async redirects() {
    return [
      {
        source: "/main",
        destination: "/",
        permanent: false,
      },
    ];
  },
};

module.exports = nextConfig;
