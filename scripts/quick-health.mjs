try {
  const r = await fetch("http://localhost:3000/api/health", { cache: "no-store" });
  const j = await r.json().catch(()=> ({}));
  console.log(r.ok ? "✅ Health OK" : "❌ Health NOT OK", j);
} catch (e) {
  console.error("❌ Health check failed:", e.message || e);
  process.exit(1);
}
