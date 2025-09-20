import { NextResponse } from "next/server";
import { appendEvent, listEvents } from "@/lib/storage";

export async function GET(_req: Request) {
  return NextResponse.json(await listEvents());
}

export async function POST(req: Request) {
  const event = await req.json().catch(() => ({}));
  await appendEvent(event);
  return NextResponse.json({ ok: true }, { status: 201 });
}
