<<<<<<< HEAD
import { NextResponse } from "next/server";
export const runtime = "nodejs";
export async function POST(req: Request){
  const data = await req.formData();
  // You can log or forward later; for now just 200 OK
  return NextResponse.json({ ok: true, received: Object.fromEntries(data as any) });
=======
import { sendMail } from "@/lib/email";
import { postLead } from "@/lib/webhook";

export const runtime = "nodejs";

function isEmail(x: unknown): x is string {
  return typeof x === "string" && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(x);
}

export async function POST(req: Request) {
  const data = await req.json().catch(() => ({} as any));

  if (!isEmail(data.email)) {
    return new Response("Invalid email", { status: 400 });
  }

  // Honeypot: ignore if bots filled it
  if (typeof data.company === "string" && data.company.trim() !== "") {
    return new Response("Ignored", { status: 204 });
  }

  const mail = await sendMail(data);
  const hook = await postLead({ source: "submit", ...data });
  const ok = mail?.ok && hook?.ok;

  return new Response(ok ? "OK" : "PARTIAL", { status: ok ? 200 : 207 });
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
}
