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
