import { NextResponse } from "next/server";
const ping = async (url: string) => { try { await fetch(url, { cache: "no-store" }); } catch {} };
export async function GET() {
  const SITE = process.env.SITE_URL || "https://your-domain.example";
  const g = `https://www.google.com/ping?sitemap=${encodeURIComponent(SITE + "/sitemap.xml")}`;
  const b = `https://www.bing.com/ping?sitemap=${encodeURIComponent(SITE + "/sitemap.xml")}`;
  await Promise.all([ping(g), ping(b)]);
  return NextResponse.json({ ok: true, pinged: [g, b] });
}
