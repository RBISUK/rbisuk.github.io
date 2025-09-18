export const dynamic = 'force-dynamic';
export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}));
    const required = ['name','email','role','link'];
    for (const k of required) if (!body[k]) return new Response(JSON.stringify({ ok:false,error:`Missing ${k}` }), { status:400 });
    return new Response(JSON.stringify({ ok:true }), { status:202 });
  } catch {
    return new Response(JSON.stringify({ ok:false }), { status:400 });
  }
}
