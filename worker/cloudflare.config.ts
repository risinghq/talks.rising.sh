import { defineConfig } from "cf/config";

// Assets only: the static export in ../site/out (wrangler.config.ts) is the whole site.
export default defineConfig({
  worker: {
    name: "talks",
    compatibilityDate: "2026-10-01",
    domains: ["talks.rising.sh"],
    workersDev: false,
  },
});
