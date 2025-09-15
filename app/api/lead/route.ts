import { postLead } from "@/lib/webhook";

export const runtime = "nodejs";

export async function POST(req: Request) {
  const data = await req.json().catch(() => ({} as any));

  if (!data || !data.name) {
    return new Response("Invalid lead data", { status: 400 });
  }

  await postLead({ source: "lead", ...data });
  return new Response("OK");
}
