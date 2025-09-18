import { test, expect } from '@playwright/test';
test('home + health', async ({ page, request }) => {
  await page.goto('/');
  await expect(page.locator('h1')).toContainText(/RBIS/i);
  const res = await request.get('/health.txt');
  expect(res.ok()).toBeTruthy();
  expect(await res.text()).toMatch(/^ok/);
});
