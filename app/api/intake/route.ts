import { NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const record = {
      ts: new Date().toISOString(),
      ip: req.headers.get("x-forwarded-for") || "unknown",
      ua: req.headers.get("user-agent") || "unknown",
      ...body,
    };

    const line = JSON.stringify(record) + "\n";
    const logPath = path.join(process.cwd(), "logs", "form-submissions.ndjson");

    await fs.appendFile(logPath, line, "utf8");

    return NextResponse.json({ ok: true });
  } catch (err: any) {
    console.error("Intake error", err);
    return NextResponse.json({ ok: false, error: err.message }, { status: 500 });
  }
}
