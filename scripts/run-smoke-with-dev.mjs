import { spawn } from "child_process";
const hosts = ["127.0.0.1","localhost"]; const ports=[...Array(11)].map((_,i)=>3000+i);
function wait(ms){return new Promise(r=>setTimeout(r,ms));}
async function healthy(){
  for (const h of hosts) for (const p of ports) {
    try { const r = await fetch(`http://${h}:${p}/api/health`, { cache:"no-store" }); if (r.ok) return { h, p }; } catch {}
  } return null;
}
async function waitForHealth(timeoutMs=40000){
  const start = Date.now();
  while (Date.now()-start < timeoutMs) { const hp = await healthy(); if (hp) return hp; await wait(500); }
  throw new Error("Dev never became healthy");
}
async function main(){
  const dev = spawn("npm", ["run","dev"], { stdio:"inherit", env:{ ...process.env, HOST:"127.0.0.1", PORT: process.env.PORT || "3000" }});
  try {
    const {h,p} = await waitForHealth(60000);
    console.log(`✅ Dev healthy on http://${h}:${p}`);
    process.env.PORT = String(p);
    const smoke = spawn("node", ["scripts/smoke-intake.mjs"], { stdio:"inherit", env:{...process.env} });
    await new Promise((res,rej)=>smoke.on("exit", c=>c===0?res(null):rej(new Error("smoke failed"))));
  } finally {
    dev.kill("SIGTERM");
  }
}
main().catch(e=>{ console.error(e); process.exit(1); });
