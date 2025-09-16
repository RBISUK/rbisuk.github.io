export const runtime = 'nodejs'; // or 'edge' if appropriate

export async function GET() {
  return Response.json({
    status: 'ok',
    buildId: process.env.VERCEL_GIT_COMMIT_SHA ?? 'local',
    ts: new Date().toISOString(),
  });
}
