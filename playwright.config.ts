import { defineConfig } from '@playwright/test';
export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  use: { baseURL: process.env.BASE_URL || 'http://localhost:3000', headless: true },
  reporter: [['list']]
});
