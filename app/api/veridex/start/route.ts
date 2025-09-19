import { NextResponse } from "next/server";
import crypto from "node:crypto";

const VERDIEX_BASE = process.env.VERDIEX_BASE_URL!;
const VERDIEX_API_KEY = process.env.VERDIEX_API_KEY!;
const ZAPIER_HOOK = process.env.ZAPIER_HOOK_URL || "";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const flow = searchParams.get("flow") || "hdr_v2";
  const sid = crypto.randomBytes(16).toString("hex");
  const payload = { sid, flow, ts: Date.now(), src: "rbis-intel-web" };
  const token = Buffer.from(JSON.stringify(payload)).toString("base64url");

  if (ZAPIER_HOOK) {
    fetch(ZAPIER_HOOK, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ event: "session_started", ...payload }) }).catch(()=>{});
  }
  const url = `${VERDIEX_BASE}/start?flow=${encodeURIComponent(flow)}&token=${token}&apikey=${VERDIEX_API_KEY}`;
  return NextResponse.redirect(url, 302);
}
