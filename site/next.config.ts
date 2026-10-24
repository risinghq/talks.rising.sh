import type { NextConfig } from "next";

// A static export: the Worker serves out/ as plain assets.
const config: NextConfig = {
  output: "export",
  trailingSlash: true,
  images: { unoptimized: true },
  // The workspace packages ship TypeScript source.
  transpilePackages: ["@slides/deck", "@slides/diversidad-vegetal"],
};

export default config;
