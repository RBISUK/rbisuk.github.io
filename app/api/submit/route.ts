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
}
