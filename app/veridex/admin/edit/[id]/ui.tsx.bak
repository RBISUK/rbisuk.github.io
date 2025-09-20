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
