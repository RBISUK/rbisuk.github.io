#!/usr/bin/env bash
set -euo pipefail

blue(){ printf "\n\033[1;34m▶ %s\033[0m\n" "$*"; }
green(){ printf "\033[1;32m✔ %s\033[0m\n" "$*"; }
red(){ printf "\033[1;31m✖ %s\033[0m\n" "$*"; }
backup_once(){ # backup_once <file>
  local f="$1"
  if [ -f "$f" ]; then
    if [ ! -f "$f.bak" ]; then
      cp "$f" "$f.bak"
      echo "  ↳ backed up $f -> $f.bak"
    else
      echo "  ↳ backup exists: $f.bak"
    fi
  fi
}

[ -f package.json ] || { red "Run this from the repo root."; exit 1; }

blue "1) Create dirs (UI + API + lib + data)"
mkdir -p app/veridex/admin app/veridex/admin/edit/[id] app/api/admin/funnels app/api/admin/funnels/[id] app/api/admin/events lib verdiex

blue "2) middleware.ts (Basic Auth + optional IP allowlist)"
backup_once middleware.ts
cat > middleware.ts <<'TS'
import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

const REALM = "RBIS Admin";

function unauthorized() {
  return new NextResponse("Unauthorized", {
    status: 401,
    headers: { "WWW-Authenticate": `Basic realm="${REALM}", charset="UTF-8"` },
  });
}

export function middleware(req: NextRequest) {
  const p = req.nextUrl.pathname;
  const protect = p.startsWith("/veridex/admin") || p.startsWith("/api/admin");
  if (!protect) return NextResponse.next();

  // Optional IP allowlist (comma-separated IPv4 in ADMIN_ALLOWLIST_IPS)
  const allow = (process.env.ADMIN_ALLOWLIST_IPS ?? "")
    .split(",")
    .map(s => s.trim())
    .filter(Boolean);

  const ip = req.ip ?? req.headers.get("x-forwarded-for")?.split(",")[0]?.trim();
  if (allow.length && ip && !allow.includes(ip)) {
    return new NextResponse("Forbidden", { status: 403 });
  }

  const hdr = req.headers.get("authorization");
  if (!hdr?.startsWith("Basic ")) return unauthorized();

  const [user, pass] = atob(hdr.slice(6)).split(":");
  if (user !== process.env.ADMIN_USER || pass !== process.env.ADMIN_PASS) {
    return unauthorized();
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/veridex/admin/:path*", "/api/admin/:path*"],
};
TS
green "middleware.ts ready"

blue "3) Storage layer (file JSON; no new deps)"
backup_once lib/storage.ts
cat > lib/storage.ts <<'TS'
import fs from "node:fs/promises";
import path from "node:path";

export type Funnel = {
  id: string;
  name: string;
  steps: any[];
  createdAt: string;
  updatedAt: string;
};

const ROOT = path.join(process.cwd(), "verdiex");
const FUNNELS = path.join(ROOT, "flows.json");
const EVENTS = path.join(ROOT, "events.json");

async function readJSON<T>(file: string, fallback: T): Promise<T> {
  try {
    const s = await fs.readFile(file, "utf8");
    return JSON.parse(s) as T;
  } catch {
    return fallback;
  }
}
async function writeJSON<T>(file: string, data: T) {
  await fs.mkdir(path.dirname(file), { recursive: true });
  await fs.writeFile(file, JSON.stringify(data, null, 2), "utf8");
}

/* Funnels CRUD */
export async function listFunnels(): Promise<Funnel[]> {
  return readJSON<Funnel[]>(FUNNELS, []);
}
export async function getFunnel(id: string): Promise<Funnel | undefined> {
  const all = await listFunnels();
  return all.find(f => f.id === id);
}
export async function createFunnel(input: Partial<Funnel>): Promise<Funnel> {
  const all = await listFunnels();
  const now = new Date().toISOString();
  const id = input.id ?? crypto.randomUUID();
  const item: Funnel = {
    id,
    name: input.name ?? "Untitled Funnel",
    steps: Array.isArray(input.steps) ? input.steps : [],
    createdAt: now,
    updatedAt: now,
  };
  all.push(item);
  await writeJSON(FUNNELS, all);
  return item;
}
export async function updateFunnel(
  id: string,
  patch: Partial<Funnel>
): Promise<Funnel | null> {
  const all = await listFunnels();
  const i = all.findIndex(f => f.id === id);
  if (i === -1) return null;
  all[i] = { ...all[i], ...patch, id, updatedAt: new Date().toISOString() };
  await writeJSON(FUNNELS, all);
  return all[i];
}
export async function deleteFunnel(id: string): Promise<boolean> {
  const all = await listFunnels();
  const next = all.filter(f => f.id !== id);
  if (next.length === all.length) return false;
  await writeJSON(FUNNELS, next);
  return true;
}

/* Events (optional) */
export async function listEvents(): Promise<any[]> {
  return readJSON<any[]>(EVENTS, []);
}
export async function appendEvent(evt: any): Promise<void> {
  const all = await listEvents();
  all.push({ ...evt, ts: new Date().toISOString() });
  await writeJSON(EVENTS, all);
}
TS
green "lib/storage.ts ready"

blue "4) Admin APIs (correct App Router signatures)"
backup_once app/api/admin/funnels/route.ts
cat > app/api/admin/funnels/route.ts <<'TS'
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
TS

backup_once app/api/admin/funnels/[id]/route.ts
cat > app/api/admin/funnels/[id]/route.ts <<'TS'
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
TS

backup_once app/api/admin/events/route.ts
cat > app/api/admin/events/route.ts <<'TS'
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
TS
green "Admin APIs ready"

blue "5) Minimal Admin UI (list/create/edit)"
backup_once app/veridex/admin/page.tsx
cat > app/veridex/admin/page.tsx <<'TSX'
import AdminUI from "./ui";

export const metadata = { title: "Veridex Admin | RBIS" };

export default function Page() {
  return <AdminUI />;
}
TSX

backup_once app/veridex/admin/ui.tsx
cat > app/veridex/admin/ui.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

type Funnel = {
  id: string;
  name: string;
  steps: any[];
  createdAt: string;
  updatedAt: string;
};

export default function AdminUI() {
  const [items, setItems] = useState<Funnel[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);
  const [newName, setNewName] = useState("");

  async function load() {
    setLoading(true);
    setErr(null);
    try {
      const res = await fetch("/api/admin/funnels", { cache: "no-store" });
      if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
      setItems(await res.json());
    } catch (e: any) {
      setErr(e.message ?? "Failed to load");
    } finally {
      setLoading(false);
    }
  }

  async function create() {
    if (!newName.trim()) return;
    const res = await fetch("/api/admin/funnels", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ name: newName }),
    });
    if (res.ok) {
      setNewName("");
      load();
    } else {
      alert("Create failed");
    }
  }

  async function remove(id: string) {
    if (!confirm("Delete this funnel?")) return;
    const res = await fetch(`/api/admin/funnels/${id}`, { method: "DELETE" });
    if (res.ok) load();
    else alert("Delete failed");
  }

  useEffect(() => { load(); }, []);

  return (
    <main className="container py-8">
      <h1 className="text-2xl font-bold">Veridex Admin</h1>

      <div className="mt-6 card p-4">
        <h2 className="font-semibold">Create Funnel</h2>
        <div className="mt-3 flex gap-2">
          <input
            className="border rounded-lg px-3 py-2 w-80"
            placeholder="Funnel name"
            value={newName}
            onChange={e => setNewName(e.target.value)}
          />
          <button className="btn-primary" onClick={create}>Create</button>
          <button className="btn" onClick={load}>Refresh</button>
        </div>
      </div>

      <div className="mt-6 card p-4">
        <h2 className="font-semibold">Funnels</h2>
        {loading && <p className="mt-3 text-sm text-neutral-600">Loading…</p>}
        {err && <p className="mt-3 text-sm text-red-600">{err}</p>}
        {!loading && !items.length && <p className="mt-3 text-sm">No funnels yet.</p>}
        {!!items.length && (
          <div className="mt-4 overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left border-b">
                  <th className="py-2">Name</th>
                  <th className="py-2">Updated</th>
                  <th className="py-2">Actions</th>
                </tr>
              </thead>
              <tbody>
                {items.map(f => (
                  <tr key={f.id} className="border-b">
                    <td className="py-2">{f.name}</td>
                    <td className="py-2">{new Date(f.updatedAt).toLocaleString()}</td>
                    <td className="py-2 flex gap-2">
                      <Link className="underline" href={`/veridex/admin/edit/${f.id}`}>Edit</Link>
                      <button className="text-red-600 underline" onClick={() => remove(f.id)}>Delete</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </main>
  );
}
TSX

backup_once app/veridex/admin/edit/[id]/page.tsx
cat > app/veridex/admin/edit/[id]/page.tsx <<'TSX'
import EditClient from "./ui";

export const metadata = { title: "Edit Funnel | Veridex Admin" };

export default function Page({ params }: { params: { id: string } }) {
  return <EditClient id={params.id} />;
}
TSX

backup_once app/veridex/admin/edit/[id]/ui.tsx
cat > app/veridex/admin/edit/[id]/ui.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

type Funnel = {
  id: string;
  name: string;
  steps: any[];
  createdAt: string;
  updatedAt: string;
};

export default function EditClient({ id }: { id: string }) {
  const [data, setData] = useState<Funnel | null>(null);
  const [name, setName] = useState("");
  const [steps, setSteps] = useState("[]");
  const [err, setErr] = useState<string | null>(null);

  async function load() {
    setErr(null);
    try {
      const res = await fetch(`/api/admin/funnels/${id}`, { cache: "no-store" });
      if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
      const f: Funnel = await res.json();
      setData(f);
      setName(f.name);
      setSteps(JSON.stringify(f.steps ?? [], null, 2));
    } catch (e: any) {
      setErr(e.message ?? "Failed to load");
    }
  }

  async function save() {
    let parsed: any[] = [];
    try {
      parsed = JSON.parse(steps);
      if (!Array.isArray(parsed)) throw new Error("Steps must be an array");
    } catch (e: any) {
      alert(\`Invalid JSON for steps: \${e.message}\`);
      return;
    }
    const res = await fetch(`/api/admin/funnels/${id}`, {
      method: "PUT",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ name, steps: parsed }),
    });
    if (res.ok) {
      await load();
      alert("Saved");
    } else {
      alert("Save failed");
    }
  }

  useEffect(() => { load(); }, [id]);

  return (
    <main className="container py-8">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Edit Funnel</h1>
        <Link href="/veridex/admin" className="underline">Back to list</Link>
      </div>

      {err && <p className="mt-3 text-sm text-red-600">{err}</p>}
      {!data && !err && <p className="mt-3 text-sm">Loading…</p>}

      {data && (
        <div className="mt-6 grid gap-6 md:grid-cols-2">
          <div className="card p-4">
            <label className="block text-sm font-medium">Name</label>
            <input
              className="mt-2 w-full border rounded-lg px-3 py-2"
              value={name}
              onChange={e => setName(e.target.value)}
            />
            <button className="mt-4 btn-primary" onClick={save}>Save</button>
          </div>

          <div className="card p-4">
            <label className="block text-sm font-medium">Steps (JSON array)</label>
            <textarea
              className="mt-2 w-full h-80 border rounded-lg px-3 py-2 font-mono text-xs"
              value={steps}
              onChange={e => setSteps(e.target.value)}
            />
          </div>
        </div>
      )}
    </main>
  );
}
TSX
green "Admin UI ready"

blue "6) Ensure Tailwind helpers exist (card/btn). Skipping if present."
if grep -q '@import "tailwindcss"' app/globals.css 2>/dev/null; then
  if ! grep -q ".card" app/globals.css; then
    cat >> app/globals.css <<'CSS'

/* Util additions (admin UI) */
.card { @apply rounded-2xl border border-neutral-200 bg-white shadow-sm; }
.btn { @apply inline-flex items-center justify-center rounded-lg px-4 py-2 font-medium; }
.btn-primary { @apply btn text-white bg-black hover:bg-neutral-800 focus:outline-none focus:ring-2 focus:ring-black/40; }
CSS
    echo "  ↳ appended .card/.btn/.btn-primary to app/globals.css"
  else
    echo "  ↳ utils already present"
  fi
else
  red "app/globals.css missing Tailwind import; ensure Tailwind is set up."
fi

blue "7) Seed empty data files if not present"
[ -f verdiex/flows.json ] || echo "[]" > verdiex/flows.json
[ -f verdiex/events.json ] || echo "[]" > verdiex/events.json
green "Data files ready (verdiex/flows.json, verdiex/events.json)"

blue "8) Build to verify"
if npm run build; then
  green "Build OK ✅"
  echo
  echo "Next steps:"
  echo "  • Ensure env vars are set in Vercel (Project → Settings → Environment Variables):"
  echo "      ADMIN_USER, ADMIN_PASS  (and optionally ADMIN_ALLOWLIST_IPS)"
  echo "  • Deploy: vercel --prod --yes"
  echo "  • Visit admin: https://<your-domain>/veridex/admin  (browser will prompt for Basic Auth)"
else
  red "Build failed — scroll up for the first error."
  exit 1
fi
