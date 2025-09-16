import { NextResponse } from "next/server";
export const runtime = "nodejs";
export async function POST(req: Request) {
  const ct = req.headers.get("content-type") || "";
  try {
    if (ct.includes("application/json")) return NextResponse.json({ ok: true, received: await req.json() });
    if (ct.includes("form")) {
      const fd = await req.formData();
      return NextResponse.json({ ok: true, received: Object.fromEntries(fd as any) });
    }
    return NextResponse.json({ ok: true, received: await req.text() });
  } catch (e: any) {
    return NextResponse.json({ ok: false, error: String(e) }, { status: 400 });
  }
}
