import { defineConfig } from "cf/config";

// Assets only: the static export in ../site/out (wrangler.config.ts) is the whole site.
export default defineConfig({
  worker: {
    name: "slides",
    compatibilityDate: "2026-10-01",
  },
});
