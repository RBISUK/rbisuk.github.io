<<<<<<< HEAD
import { NextResponse } from "next/server";
export const runtime = "nodejs";
export async function GET(){ return NextResponse.json({ ok:true, service:"rbisuk", time:new Date().toISOString() }); }
=======
export const runtime = 'nodejs'; // or 'edge' if appropriate

export async function GET() {
  return Response.json({
    status: 'ok',
    buildId: process.env.VERCEL_GIT_COMMIT_SHA ?? 'local',
    ts: new Date().toISOString(),
  });
}
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
