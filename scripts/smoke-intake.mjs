import fetch from "node-fetch";
import fs from "fs";
import path from "path";

const base = process.env.BASE || "http://127.0.0.1:3000";
const logFile = path.join(process.cwd(), "logs", "form-submissions.ndjson");
function rand(n=9999){ return Math.floor(Math.random()*n); }

try {
  const res = await fetch(`${base}/api/submit`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      product: "Housing Disrepair",
      client: { title: "Mr", firstName: "Smoke", middleName: "", lastName: "Test"+rand(), mobile: "07123456789", email: `smoke${rand()}@example.com` },
      issue: { type: "Damp/Mould", duration: "6 months", postcode:"M1 2AB" },
      upsell: { debts: true },
      utm: { utm_source: "smoke", utm_campaign: "qa" },
      website: "",
      evidence: []
    })
  });
  if (!res.ok) {
    const txt = await res.text();
    console.error("❌ Smoke intake FAILED:", res.status, txt.slice(0,200));
    process.exit(1);
  }
  await new Promise(r => setTimeout(r, 200));
  const tail = fs.existsSync(logFile) ? fs.readFileSync(logFile, "utf8").trim().split("\n").slice(-1)[0] : "";
  console.log("✅ Smoke intake OK");
  if (tail) console.log("Last log:", tail);
  process.exit(0);
} catch (e) {
  console.error("❌ Smoke intake FAILED:", e.message || e);
  process.exit(1);
}
