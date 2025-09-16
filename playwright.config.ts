import type { PlaywrightTestConfig } from '@playwright/test';

const PORT = process.env.PORT || '3100';

const config: PlaywrightTestConfig = {
  timeout: 30_000,
  use: { baseURL: `http://127.0.0.1:${PORT}`, headless: true },
  webServer: {
    command: `PORT=${PORT} node scripts/dev.mjs`,
    url: `http://127.0.0.1:${PORT}`,
    reuseExistingServer: true,
    timeout: 60_000
  }
};

export default config;
