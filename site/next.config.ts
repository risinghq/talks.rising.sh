import createMDX from "@next/mdx";
import { createRequire } from "node:module";
import type { NextConfig } from "next";

// A static export: the Worker serves out/ as plain assets.
const config: NextConfig = {
  output: "export",
  trailingSlash: true,
  images: { unoptimized: true },
  // The workspace packages ship TypeScript and MDX source.
  transpilePackages: ["@slides/deck", "@slides/deploy-django", "@slides/diversidad-vegetal"],
};

// Turbopack runs the MDX plugins in Rust, so they are named by string with
// serializable options. The loader resolves a bare name from the workspace
// root, where the site's dependencies are not installed, so each is an
// absolute path. Shiki highlights code at build time.
const plugin = createRequire(import.meta.url).resolve;
const withMDX = createMDX({
  options: {
    remarkPlugins: [plugin("remark-gfm")],
    rehypePlugins: [[plugin("@shikijs/rehype"), { theme: "github-light" }]],
  },
});

export default withMDX(config);
