<<<<<<< HEAD
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
=======
import fs from "fs";
import path from "path";

const hosts = ["127.0.0.1","localhost"];
const ports = Array.from({length:11}, (_,i)=>3000+i); // 3000..3010

async function probe(url){
  try { const r = await fetch(url, { cache:"no-store" }); return r.ok; } catch { return false; }
}

async function findBaseUrl(timeoutMs=30000){
  const start = Date.now();
  while (Date.now()-start < timeoutMs) {
    for (const h of hosts) for (const p of ports) {
      if (await probe(`http://${h}:${p}/api/health`)) return `http://${h}:${p}`;
    }
    await new Promise(r=>setTimeout(r,400));
  }
  throw new Error("Dev server not reachable on 127.0.0.1/localhost:3000-3010");
}

function isValidEmail(e){return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e||"");}
function isValidUKMobile(m){const s=(m||"").replace(/\s+/g,"");return /^(07\d{9}|(\+44|44)7\d{9})$/.test(s);}

async function run(){
  const base = await findBaseUrl();
  console.log("ℹ️ Using base:", base);
  const payload = {
    product: "Housing Disrepair",
    client: { title:"Ms", firstName:"Smoke", middleName:"", lastName:"Test", mobile:"07123456789", email:"smoke@example.com" },
    issue: { type:"Damp/Mould", duration:"12 months", description:"Persistent black mould on kitchen ceiling" }
  };
  if (!isValidEmail(payload.client.email)) throw new Error("email regex failed");
  if (!isValidUKMobile(payload.client.mobile)) throw new Error("mobile regex failed");

  const res = await fetch(`${base}/api/submit`, {
    method:"POST", headers:{ "content-type":"application/json" }, body: JSON.stringify(payload)
  }).catch(e=>{ throw new Error("fetch failed: "+(e?.message||e)); });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Server responded ${res.status} ${text.slice(0,300)}`);
  }

  const logFile = path.join(process.cwd(), "logs", "form-submissions.ndjson");
  const tail = fs.existsSync(logFile) ? fs.readFileSync(logFile, "utf8").trim().split("\n").slice(-1)[0] : "";
  console.log("✅ Submit OK. Last log entry:", tail);
}
run().catch(e=>{ console.error("❌ Smoke intake FAILED:", e.message||e); process.exit(1); });
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
