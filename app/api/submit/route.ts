import { NextResponse } from "next/server";
export const runtime = "nodejs";
export async function POST(req: Request){
  const data = await req.formData();
  // You can log or forward later; for now just 200 OK
  return NextResponse.json({ ok: true, received: Object.fromEntries(data as any) });
}
