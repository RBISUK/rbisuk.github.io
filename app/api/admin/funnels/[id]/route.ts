import { NextResponse } from "next/server";
import { getFunnel, updateFunnel, deleteFunnel } from "@/lib/storage";

export async function GET(_req: Request, { params }: { params: { id: string } }) {
  const funnel = await getFunnel(params.id);
  if (!funnel) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json(funnel);
}

export async function PUT(req: Request, { params }: { params: { id: string } }) {
  const patch = await req.json().catch(() => ({}));
  const updated = await updateFunnel(params.id, patch);
  if (!updated) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json(updated);
}

export async function DELETE(_req: Request, { params }: { params: { id: string } }) {
  const ok = await deleteFunnel(params.id);
  if (!ok) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json({ ok: true });
}
