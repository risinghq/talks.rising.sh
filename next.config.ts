import type { NextConfig } from "next";

// A static export: the Worker serves out/ as plain assets.
const config: NextConfig = { output: "export", trailingSlash: true, images: { unoptimized: true } };

export default config;
