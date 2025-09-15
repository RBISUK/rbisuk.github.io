import { NextResponse } from "next/server";
import fs from "fs";
import path from "path";
import { sendMail } from "@/lib/email";
import { postLead } from "@/lib/webhook";

export const runtime = "nodejs";

function isValidEmail(email: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email || "");
}
function isValidUKMobile(m: string) {
  const s = (m || "").replace(/\s+/g, "");
  return /^(07\d{9}|(\+44|44)7\d{9})$/.test(s);
}

// tiny in-memory rate limit per minute
const bucket: Record<string, { count: number; ts: number }> = {};
function rateLimit(ip: string | null) {
  const key = ip || "unknown";
  const now = Date.now(), win = 60_000;
  const rec = bucket[key] || { count: 0, ts: now };
  if (now - rec.ts > win) { rec.count = 0; rec.ts = now; }
  rec.count++; bucket[key] = rec;
  return rec.count <= 30;
}

export async function POST(req: Request) {
  try {
    const ip = req.headers.get("x-forwarded-for") || null;
    if (!rateLimit(ip)) return NextResponse.json({ ok:false, error:"rate_limited" }, { status:429 });

    const body = await req.json().catch(() => ({}));
    const { product, client = {}, issue = {} } = body || {};

    if (!product) return NextResponse.json({ ok:false, error:"missing_product" }, { status:400 });
    if (!isValidEmail(client.email || "")) return NextResponse.json({ ok:false, error:"invalid_email" }, { status:400 });
    if (!isValidUKMobile(client.mobile || "")) return NextResponse.json({ ok:false, error:"invalid_mobile" }, { status:400 });

    const record = {
      ts: new Date().toISOString(),
      ip,
      ua: req.headers.get("user-agent") || "",
      product,
      client,
      issue,
    };

    const logFile = path.join(process.cwd(), "logs", "form-submissions.ndjson");
    fs.mkdirSync(path.dirname(logFile), { recursive: true });
    fs.appendFileSync(logFile, JSON.stringify(record) + "\n", "utf8");

    const subject = `New ${product} intake: ${client.firstName || ""} ${client.lastName || ""}`.trim();
    await sendMail({ to: process.env.NOTIFY_TO || "ops@rbis.uk", subject, text: JSON.stringify(record, null, 2) }).catch(() => null);
    await postLead(process.env.CRM_WEBHOOK_URL, record).catch(() => null);

    return NextResponse.json({ ok: true });
  } catch (e: any) {
    console.error("submit error:", e?.message || e);
    return NextResponse.json({ ok:false, error:"server_error" }, { status:500 });
  }
}

export async function GET() {
  return NextResponse.json({ ok: true, route: "submit" });
}
