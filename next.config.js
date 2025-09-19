/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          { key: "X-Frame-Options", value: "SAMEORIGIN" },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
          { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
          { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" }
        ]
      }
    ];
  },

  async rewrites() {
    return [
      // If the request Host is hdr.rbisintelligence.com, serve the /hdr app
      {
        source: "/:path*",
        has: [{ type: "host", value: "hdr.rbisintelligence.com" }],
        destination: "/hdr/:path*"
      }
    ];
  }
};

module.exports = nextConfig;
