import { defineConfig } from "@playwright/test";

const PORT = 3045; // single source of truth

export default defineConfig({
  use: {
    baseURL: process.env.BASE_URL || `http://localhost:${PORT}`,
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    video: "off",
  },
  webServer: {
    // build once then start prod server; reuse when already running locally
    command: `npm run build && next start -p ${PORT}`,
    port: PORT,
    reuseExistingServer: true,
    timeout: 120_000,
  },
});
