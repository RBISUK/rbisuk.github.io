"use client";
import { useState } from "react";

export default function SimpleForm() {
  const [msg, setMsg] = useState("");

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const data = new FormData(e.currentTarget);
    const r = await fetch("/api/submit", { method: "POST", body: data });
    setMsg(JSON.stringify(await r.json(), null, 2));
  }

  return (
    <main className="p-8 space-y-4">
      <h1>Contact</h1>
      <form onSubmit={onSubmit} className="space-y-3 max-w-xl">
        <input name="name" placeholder="Name" className="border p-2 w-full" />
        <input name="email" placeholder="Email" className="border p-2 w-full" />
        <textarea name="message" placeholder="Message" className="border p-2 w-full" />
        <button className="border px-4 py-2">Send</button>
      </form>
      {msg && <pre className="bg-gray-100 p-3 whitespace-pre-wrap">{msg}</pre>}
    </main>
  );
}
