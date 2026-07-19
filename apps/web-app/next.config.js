/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: {
    serverActions: true,
  },
  transpilePackages: ['@pulsegrid/ui', '@pulsegrid/webrtc-sdk', '@pulsegrid/crypto-utils'],
};

module.exports = nextConfig;
