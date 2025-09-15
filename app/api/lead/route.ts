import { NextResponse } from "next/server";
import { writeFile, mkdir } from "fs/promises";
import { existsSync } from "fs";
import path from "path";

const LOG_DIR = process.env.RBIS_LOG_DIR || "/workspaces/rbisuk.github.io/logs";
const LOG_FILE = path.join(LOG_DIR, "form-submissions.ndjson");

export async function POST(req: Request) {
  try {
    const body = await req.json();

    // Basic required checks
    if (!body?.claimType) return NextResponse.json({ ok:false, error:"claimType required" }, { status: 400 });
    if (!body?.consent?.processing || !body?.consent?.terms) {
      return NextResponse.json({ ok:false, error:"Explicit consent required" }, { status: 400 });
    }

    // Ensure log dir
    if (!existsSync(LOG_DIR)) {
      await mkdir(LOG_DIR, { recursive: true });
    }

    const entry = {
      _v: 1,
      ts: new Date().toISOString(),
      ip: req.headers.get("x-forwarded-for") || "127.0.0.1",
      ua: req.headers.get("user-agent") || null,
      claim: body,
    };

    await writeFile(LOG_FILE, JSON.stringify(entry) + "\n", { flag: "a" });
    return NextResponse.json({ ok: true });
  } catch (e: any) {
    return NextResponse.json({ ok:false, error: e?.message || "bad request" }, { status: 400 });
  }
}
