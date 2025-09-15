/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Uncomment if you want static export for GitHub Pages
  // output: 'export',
  experimental: {
    optimizePackageImports: ['lucide-react', 'framer-motion'],
  },
};
export default nextConfig;
