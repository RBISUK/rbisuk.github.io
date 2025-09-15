import { test, expect } from "@playwright/test";

test.describe("API: /api/submit", () => {
  test("rejects bad email", async ({ request, baseURL }) => {
    const res = await request.post(`${baseURL}/api/submit`, {
      data: { email: "nope" }
    });
    expect(res.status()).toBe(400);
  });

  test("accepts valid submit", async ({ request, baseURL }) => {
    const res = await request.post(`${baseURL}/api/submit`, {
      data: { email: "user@example.com", name: "Ryan", message: "Hello!" }
    });
    expect([200, 207]).toContain(res.status());
  });
});

test.describe("API: /api/intake", () => {
  test("rejects missing type", async ({ request, baseURL }) => {
    const res = await request.post(`${baseURL}/api/intake`, { data: {} });
    expect(res.status()).toBe(400);
  });

  test("accepts valid intake", async ({ request, baseURL }) => {
    const res = await request.post(`${baseURL}/api/intake`, {
      data: { type: "hdr-enquiry", email: "a@b.co" }
    });
    expect([200, 207]).toContain(res.status());
  });
});

test.describe("API: /api/lead", () => {
  test("rejects missing fields", async ({ request, baseURL }) => {
    const res = await request.post(`${baseURL}/api/lead`, { data: {} });
    expect(res.status()).toBe(400);
  });

  test("accepts valid lead", async ({ request, baseURL }) => {
    const res = await request.post(`${baseURL}/api/lead`, {
      data: { name: "Alex", phone: "+44 1234 567890" }
    });
    expect([200, 207]).toContain(res.status());
  });
});
