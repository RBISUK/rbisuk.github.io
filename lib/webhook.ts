export async function postLead(url: string | undefined, payload: any) {
  if (!url) { console.log("[webhook:stub] no CRM_WEBHOOK_URL set"); return { ok: true }; }
  try {
    const r = await fetch(url, { method: "POST", headers: {"content-type":"application/json"}, body: JSON.stringify(payload) });
    console.log("[webhook:stub] status:", r.status);
  } catch(e) { console.log("[webhook:stub] failed:", (e as any)?.message || e); }
  return { ok: true };
}
