import { z } from "zod";
import { rateLimit } from "@/app/lib/rateLimit";
import { writeFile, mkdir } from "fs/promises";
import { randomUUID } from "crypto";
import { join } from "path";

const LeadSchema = z.object({
  name: z.string().min(1),
  email: z.string().email().optional(),
  phone: z.string().min(5).optional(),
  source: z.string().min(1),
  campaign: z.string().min(1),
  channel: z.string().optional(),
  utm: z.object({
    source: z.string().optional(),
    medium: z.string().optional(),
    campaign: z.string().optional(),
    term: z.string().optional(),
    content: z.string().optional(),
  }).optional(),
  consent: z.object({
    contact: z.boolean().default(true),
    store: z.boolean().default(true),
  }).optional(),
  tenantId: z.string().optional(),
  module: z.string().optional(),
  leadType: z.string().optional(),
});

function checkApiKey(req: Request) {
  const required = (process.env.API_KEY || "").trim();
  if (!required) return { ok: true };
  const provided = (req.headers.get("x-api-key") || "").trim();
  return { ok: provided === required, reason: "Invalid or missing x-api-key" };
}

async function postWebhook(url: string, payload: unknown) {
  try {
    const r = await fetch(url, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(payload) });
    return r.ok;
  } catch { return false; }
}

async function appendJSONL(dir: string, line: unknown) {
  const p = join(process.cwd(), dir, "leads.jsonl");
  await mkdir(join(process.cwd(), dir), { recursive: true });
  await writeFile(p, JSON.stringify(line) + "\n", { flag: "a" });
}

export async function POST(req: Request) {
  // Rate limit
  const rl = rateLimit(req, { windowMs: 60_000, max: 60 }); // 60/min/IP
  if (!rl.ok) return Response.json({ error: "Too Many Requests" }, { status: 429 });

  // Content-Type
  const ct = req.headers.get("content-type") || "";
  if (!ct.includes("application/json")) {
    return Response.json({ error: "Content-Type must be application/json" }, { status: 400 });
  }

  // API key (optional)
  const key = checkApiKey(req);
  if (!key.ok) return Response.json({ error: key.reason }, { status: 401 });

  // Parse + validate
  let json: unknown = null;
  try { json = await req.json(); } catch {}
  if (!json) return Response.json({ error: "Invalid JSON body" }, { status: 400 });

  const parsed = LeadSchema.safeParse(json);
  if (!parsed.success) {
    return Response.json({
      error: "ValidationError",
      issues: parsed.error.issues.map(i => ({ path: i.path.join("."), message: i.message })),
    }, { status: 400 });
  }
  const lead = parsed.data;
  if (!lead.email && !lead.phone) {
    return Response.json({ error: "Provide email or phone" }, { status: 400 });
  }

  // Build record
  const id = randomUUID();
  const record = {
    id,
    receivedAt: new Date().toISOString(),
    ...lead,
    env: process.env.NODE_ENV || "development"
  };

  // Audit JSONL (local evidence)
  await appendJSONL("logs", record);

  // Webhook (optional)
  let webhookOk = true;
  const url = (process.env.LEAD_WEBHOOK_URL || "").trim();
  if (url) webhookOk = await postWebhook(url, record);

  // Log to stdout for pm2 logs
  console.log("[LEAD] accepted", { id, name: lead.name, email: lead.email, phone: lead.phone, campaign: lead.campaign, webhookOk });

  return Response.json({ ok: true, id, receivedAt: record.receivedAt, webhookOk }, { status: 201 });
}

export async function GET() {
  return Response.json({ ok: true, info: "POST a JSON lead payload to this endpoint" });
}
