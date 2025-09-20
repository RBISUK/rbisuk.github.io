#!/usr/bin/env bash
set -euo pipefail
echo "▶ Creating admin + storage + auth"

mkdir -p lib app/veridex/admin app/veridex/admin/edit/[id] app/api/admin/funnels app/api/admin/funnels/[id] app/api/admin/events

############################################
# 1) Storage adapter (FS for dev, KV for prod)
############################################
cat > lib/storage.ts <<'TS'
import fs from "node:fs";
import path from "node:path";

const isKV = !!(process.env.KV_REST_API_URL && process.env.KV_REST_API_TOKEN);
const KV_URL = process.env.KV_REST_API_URL;
const KV_TOKEN = process.env.KV_REST_API_TOKEN;

const R = (p:string)=> path.join(process.cwd(), p);

export type Funnel = { id:string; name:string; steps:any[]; [k:string]:any };

async function kvGet(key:string){
  const r = await fetch(`${KV_URL}/get/${encodeURIComponent(key)}`, {
    headers:{ Authorization: `Bearer ${KV_TOKEN}` },
    cache: "no-store"
  });
  if (!r.ok) return null;
  return (await r.json())?.result ?? null;
}
async function kvSet(key:string, value:any){
  await fetch(`${KV_URL}/set/${encodeURIComponent(key)}`, {
    method:"POST",
    headers:{ Authorization: `Bearer ${KV_TOKEN}`, "Content-Type":"application/json" },
    body: JSON.stringify(value)
  });
}
async function kvDel(key:string){
  await fetch(`${KV_URL}/delete/${encodeURIComponent(key)}`, {
    method:"POST",
    headers:{ Authorization: `Bearer ${KV_TOKEN}` }
  });
}
async function kvList(prefix:string){
  const r = await fetch(`${KV_URL}/keys?prefix=${encodeURIComponent(prefix)}`, {
    headers:{ Authorization: `Bearer ${KV_TOKEN}` }, cache:"no-store"
  });
  if (!r.ok) return [];
  const { result } = await r.json();
  return result as { key:string }[];
}

export const storage = {
  async listFunnels(): Promise<Funnel[]> {
    if (isKV) {
      const keys = await kvList("veridex:funnel:");
      const out: Funnel[] = [];
      for (const {key} of keys) {
        const v = await kvGet(key);
        if (v) out.push(v);
      }
      return out.sort((a,b)=>a.name.localeCompare(b.name));
    }
    // FS (dev)
    const dir = R("verdiex/config");
    if (!fs.existsSync(dir)) return [];
    return fs.readdirSync(dir)
      .filter(f=>f.endsWith(".json"))
      .map(f=>JSON.parse(fs.readFileSync(path.join(dir,f),"utf8")) as Funnel)
      .sort((a,b)=>a.name.localeCompare(b.name));
  },

  async getFunnel(id:string): Promise<Funnel|null> {
    if (isKV) return await kvGet(`veridex:funnel:${id}`);
    const p = R(`verdiex/config/${id}.json`);
    if (!fs.existsSync(p)) return null;
    return JSON.parse(fs.readFileSync(p,"utf8"));
  },

  async putFunnel(f:Funnel): Promise<void> {
    if (!f.id) throw new Error("Funnel.id required");
    if (isKV) return kvSet(`veridex:funnel:${f.id}`, f);
    const dir = R("verdiex/config");
    fs.mkdirSync(dir, { recursive:true });
    fs.writeFileSync(path.join(dir, `${f.id}.json`), JSON.stringify(f,null,2));
  },

  async deleteFunnel(id:string): Promise<void> {
    if (isKV) return kvDel(`veridex:funnel:${id}`);
    const p = R(`verdiex/config/${id}.json`);
    if (fs.existsSync(p)) fs.rmSync(p);
  },

  async appendEvent(event:any): Promise<void> {
    if (isKV) {
      const key = `veridex:event:${Date.now()}:${Math.random().toString(36).slice(2)}`;
      await kvSet(key, event);
      return;
    }
    const dir = R("verdiex/events");
    fs.mkdirSync(dir, { recursive:true });
    const p = path.join(dir, `${Date.now()}-${Math.random().toString(36).slice(2)}.json`);
    fs.writeFileSync(p, JSON.stringify(event, null, 2));
  },

  async listEvents(limit=100): Promise<any[]> {
    if (isKV) {
      const keys = await kvList("veridex:event:");
      const recent = keys.sort((a,b)=> b.key.localeCompare(a.key)).slice(0, limit);
      const out:any[] = [];
      for (const {key} of recent) {
        const v = await kvGet(key);
        if (v) out.push(v);
      }
      return out;
    }
    const dir = R("verdiex/events");
    if (!fs.existsSync(dir)) return [];
    const files = fs.readdirSync(dir).sort().reverse().slice(0, limit);
    return files.map(f=>JSON.parse(fs.readFileSync(path.join(dir,f),"utf8")));
  }
};
TS

############################################
# 2) Admin APIs (CRUD + events)
############################################
cat > app/api/admin/funnels/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { storage } from "@/lib/storage";
export async function GET() {
  const list = await storage.listFunnels();
  return NextResponse.json({ ok:true, list });
}
export async function POST(req: NextRequest) {
  const body = await req.json();
  if (!body?.id || !body?.name || !Array.isArray(body?.steps)) {
    return NextResponse.json({ ok:false, error:"id, name, steps required" }, { status:400 });
  }
  await storage.putFunnel(body);
  return NextResponse.json({ ok:true });
}
TS

cat > app/api/admin/funnels/[id]/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { storage } from "@/lib/storage";
export async function GET(_: NextRequest, { params }: { params: { id:string }}) {
  const f = await storage.getFunnel(params.id);
  if (!f) return NextResponse.json({ ok:false }, { status:404 });
  return NextResponse.json({ ok:true, funnel:f });
}
export async function PUT(req: NextRequest, { params }: { params: { id:string }}) {
  const body = await req.json();
  if (!body?.id || body.id !== params.id) {
    return NextResponse.json({ ok:false, error:"id mismatch" }, { status:400 });
  }
  await storage.putFunnel(body);
  return NextResponse.json({ ok:true });
}
export async function DELETE(_: NextRequest, { params }: { params: { id:string }}) {
  await storage.deleteFunnel(params.id);
  return NextResponse.json({ ok:true });
}
TS

cat > app/api/admin/events/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { storage } from "@/lib/storage";
export async function GET(req: NextRequest) {
  const limit = Number(new URL(req.url).searchParams.get("limit") ?? "100");
  const items = await storage.listEvents(limit);
  return NextResponse.json({ ok:true, items });
}
TS

############################################
# 3) Admin UI (list + editor)
############################################
cat > app/veridex/admin/page.tsx <<'TSX'
"use client";
import Link from "next/link";
import { useEffect, useState } from "react";

type Funnel = { id:string; name:string; steps:any[]; [k:string]:any };

export default function AdminHome(){
  const [list, setList] = useState<Funnel[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(()=>{
    fetch("/api/admin/funnels", { cache:"no-store" })
      .then(r=>r.json()).then(d=>{ setList(d.list||[]); setLoading(false); });
  },[]);

  if (loading) return <main className="container py-10">Loading…</main>;

  return (
    <main className="container py-10">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Veridex Funnels</h1>
        <Link href="/veridex/admin/edit/new" className="btn-primary">New funnel</Link>
      </div>

      <div className="mt-6 grid gap-3">
        {list.map(f => (
          <div key={f.id} className="card p-4 flex items-center justify-between">
            <div>
              <div className="font-semibold">{f.name}</div>
              <div className="text-sm text-neutral-600">{f.id} • {f.steps?.length ?? 0} steps</div>
            </div>
            <div className="flex gap-2">
              <Link className="btn border border-neutral-300" href={`/veridex/admin/edit/${f.id}`}>Edit</Link>
              <button className="btn border border-red-300 text-red-700" onClick={async ()=>{
                if (!confirm(`Delete ${f.name}?`)) return;
                await fetch(`/api/admin/funnels/${f.id}`, { method:"DELETE" });
                location.reload();
              }}>Delete</button>
            </div>
          </div>
        ))}
      </div>

      <section className="mt-10">
        <h2 className="text-xl font-bold">Recent events</h2>
        <Events />
      </section>
    </main>
  );
}

function Events(){
  const [events, setEvents] = useState<any[]>([]);
  useEffect(()=>{
    fetch("/api/admin/events?limit=50", { cache:"no-store" })
      .then(r=>r.json()).then(d=> setEvents(d.items||[]));
  },[]);
  if (!events.length) return <p className="mt-3 text-sm text-neutral-600">No events yet.</p>;
  return (
    <div className="mt-4 grid gap-2">
      {events.map((e,i)=>(
        <pre key={i} className="overflow-auto p-3 rounded-lg bg-neutral-50 border text-xs">
{JSON.stringify(e, null, 2)}
        </pre>
      ))}
    </div>
  );
}
TSX

cat > app/veridex/admin/edit/[id]/page.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";

type Funnel = { id:string; name:string; steps:any[]; [k:string]:any };

export default function Editor(){
  const params = useParams<{ id:string }>();
  const router = useRouter();
  const [jsonText, setJsonText] = useState<string>("");
  const [isNew, setIsNew] = useState<boolean>(false);
  const [error, setError] = useState<string| null>(null);

  useEffect(()=>{
    const id = params.id;
    if (id === "new") {
      setIsNew(true);
      setJsonText(JSON.stringify({
        id: "new-funnel-id",
        name: "New Funnel",
        steps: [
          { id:"entry", title:"Welcome", prompt:"Choose one", type:"single",
            options:[ { value:"a", label:"Option A", next:"finish" }, { value:"b", label:"Option B", next:"finish" } ],
            next:"finish"
          },
          { id:"finish", title:"Done", prompt:"Thanks!", type:"text" }
        ],
        compliance: { region:"UK", regimes:["GDPR"] }
      }, null, 2));
      return;
    }
    fetch(`/api/admin/funnels/${id}`, { cache:"no-store" })
      .then(r=> r.ok ? r.json() : Promise.reject("Not found"))
      .then(d=> setJsonText(JSON.stringify(d.funnel, null, 2)))
      .catch(()=> setError("Could not load funnel"));
  },[params.id]);

  async function save() {
    try {
      const obj = JSON.parse(jsonText) as Funnel;
      if (isNew) {
        const r = await fetch("/api/admin/funnels", {
          method:"POST", headers:{ "Content-Type":"application/json" }, body: JSON.stringify(obj)
        });
        if (!r.ok) throw new Error("Save failed");
        router.push(`/veridex/admin/edit/${obj.id}`);
      } else {
        const r = await fetch(`/api/admin/funnels/${obj.id}`, {
          method:"PUT", headers:{ "Content-Type":"application/json" }, body: JSON.stringify(obj)
        });
        if (!r.ok) throw new Error("Save failed");
        alert("Saved");
      }
    } catch (e:any) {
      alert(e.message || "Invalid JSON");
    }
  }

  return (
    <main className="container py-10">
      <h1 className="text-2xl font-bold">Funnel Editor</h1>
      {error && <p className="mt-2 text-red-700">{error}</p>}
      <textarea value={jsonText} onChange={e=>setJsonText(e.target.value)}
        className="mt-4 w-full h-[60vh] rounded-lg border p-3 font-mono text-sm" />
      <div className="mt-3 flex gap-2">
        <button onClick={save} className="btn-primary">Save</button>
        <button onClick={()=>history.back()} className="btn border border-neutral-300">Back</button>
      </div>
      <p className="mt-6 text-sm text-neutral-600">
        Tip: branch with <code>next</code> on options, and add <code>compliance.regimes</code> (e.g. ["GDPR","SRA","FCA","ASA"]).
      </p>
    </main>
  );
}
TSX

############################################
# 4) Middleware – Basic Auth (+ optional IP allowlist)
############################################
cat > middleware.ts <<'TS'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const PROTECT = [/^\/veridex\/admin/, /^\/api\/admin/];

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Protect admin routes
  if (PROTECT.some(r=>r.test(pathname))) {
    const allowIPs = (process.env.ADMIN_ALLOWLIST_IPS || "").split(",").map(s=>s.trim()).filter(Boolean);
    const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() || "0.0.0.0";
    if (allowIPs.length && !allowIPs.includes(ip)) {
      return new NextResponse("Forbidden (IP)", { status: 403 });
    }

    const auth = req.headers.get("authorization") || "";
    const expectUser = process.env.ADMIN_USER || "";
    const expectPass = process.env.ADMIN_PASS || "";
    if (!expectUser || !expectPass) {
      return new NextResponse("Admin creds not set", { status: 500 });
    }
    const ok = (() => {
      if (!auth.startsWith("Basic ")) return false;
      const given = Buffer.from(auth.slice(6), "base64").toString("utf8");
      return given === `${expectUser}:${expectPass}`;
    })();
    if (!ok) {
      const res = new NextResponse("Auth required", { status: 401 });
      res.headers.set("WWW-Authenticate", 'Basic realm="RBIS Admin", charset="UTF-8"');
      return res;
    }
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/veridex/admin/:path*", "/api/admin/:path*"]
};
TS

############################################
# 5) Event log API endpoint used by runner
############################################
cat > app/api/track/eventlog/route.ts <<'TS'
import { NextRequest, NextResponse } from "next/server";
import { storage } from "@/lib/storage";
export async function POST(req: NextRequest) {
  const body = await req.json().catch(()=> ({}));
  await storage.appendEvent({ ts: Date.now(), ...body });
  return NextResponse.json({ ok:true });
}
TS

echo "✅ Admin, storage, middleware, APIs created."
