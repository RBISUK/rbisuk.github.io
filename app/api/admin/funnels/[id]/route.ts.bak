import { NextResponse } from "next/server";
import { listFunnels, createFunnel } from "@/lib/storage";

export async function GET(_req: Request) {
  const items = await listFunnels();
  return NextResponse.json(items);
}

export async function POST(req: Request) {
  const body = await req.json().catch(() => ({}));
  const created = await createFunnel(body);
  return NextResponse.json(created, { status: 201 });
}
