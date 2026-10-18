import { createMDX } from 'fumadocs-mdx/next';

const withMDX = createMDX();

/** @type {import('next').NextConfig} */
const config = {
  output: 'export',
  // Keep in sync with basePath in lib/shared.ts.
  basePath: '/nix',
  // Export every page as <path>/index.html, which GitHub Pages serves directly.
  trailingSlash: true,
  reactStrictMode: true,
};

export default withMDX(config);
