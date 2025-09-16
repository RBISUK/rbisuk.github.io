import { postLead } from "@/lib/webhook";

export const runtime = "nodejs";

export async function POST(req: Request) {
  const data = await req.json().catch(() => ({} as any));

  if (!data || typeof data !== "object") {
    return new Response("Invalid data", { status: 400 });
  }

  await postLead({ source: "intake", ...data });
  return new Response("OK");
}
