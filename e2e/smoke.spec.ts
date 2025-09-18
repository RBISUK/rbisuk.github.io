import { test, expect } from "@playwright/test";

const pages = [
  "/", "/solutions", "/veridex", "/pact-ledger",
  "/contact", "/privacy", "/hdr", "/trust-centre",
];
const assets = [
  "/health.txt",
  "/trust/subprocessors/list.json",
  "/trust/status/current.json",
  "/trust/evidence/2025-Q4/Compliance_Evidence_Pack.txt",
];

for (const p of pages) {
  test(`page 200: ${p}`, async ({ page }) => {
    const res = await page.goto(p);
    expect(res, `GET ${p} returned ${res?.status()}`).toBeTruthy();
    expect(res!.ok(), `GET ${p} returned ${res!.status()}`).toBeTruthy();
  });
}

for (const a of assets) {
  test(`asset 200: ${a}`, async ({ request }) => {
    const res = await request.get(a);
    expect(res.ok(), `GET ${a} returned ${res.status()}`).toBeTruthy();
    if (a.endsWith(".json")) {
      const j = await res.json();
      expect(typeof j).toBe("object");
    } else {
      const text = (await res.text()).trim();
      expect(text.length).toBeGreaterThan(0);
    }
  });
}

