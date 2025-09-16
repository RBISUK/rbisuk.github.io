import { test, expect } from '@playwright/test';

test('HDR landing loads', async ({ page }) => {
  await page.goto('/hdr');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText(/HDR Funnel/i);
});

test('RBIS main loads', async ({ page }) => {
  await page.goto('/main');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText(/RBIS — Main/i);
});

test('Key subpages respond', async ({ page }) => {
  const checks: [string, RegExp][] = [
    ['/hdr/pricing', /Pricing/i],
    ['/hdr/what-it-does', /What it does/i],
    ['/hdr/trust', /Trust/i],
    ['/hdr/value', /Value/i],
    ['/main/value', /(RBIS Value|Value)/i],
  ];
  for (const [path, rx] of checks) {
    await page.goto(path);
    await expect(page.locator('h1')).toHaveText(rx);
  }
});
