// lib/webhook.ts
// One env var, many tools: Zapier/Make/HubSpot webhook, CRMs, etc.
// Set WEBHOOK_URL and you’re done.

export async function postLead(data: any) {
  if (!process.env.WEBHOOK_URL) {
    console.log("🔗 [DEV webhook] ->", JSON.stringify(data));
    return { ok: true, provider: "dev-log" };
  }
  const res = await fetch(process.env.WEBHOOK_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  });
  return { ok: res.ok, status: res.status };
}
