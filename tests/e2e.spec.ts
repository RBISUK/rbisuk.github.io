import { test, expect } from '@playwright/test';
const BASE = process.env.E2E_BASE_URL || 'http://localhost:4010';

test('HDR landing loads', async ({ page }) => {
  const res = await page.goto(`${BASE}/hdr`, { waitUntil: 'networkidle' });
  expect(res?.ok()).toBeTruthy();
  await expect(page.locator('h1')).toBeVisible();
});

test('RBIS main loads', async ({ page }) => {
  const res = await page.goto(`${BASE}/main`, { waitUntil: 'networkidle' });
  expect(res?.ok()).toBeTruthy();
  await expect(page.locator('h1')).toBeVisible();
});
