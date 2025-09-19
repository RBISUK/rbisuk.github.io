import { spawn } from "child_process";
const routes = ["/", "/hdr", "/products", "/products/claim-fix-ai"];
function curl(url){return new Promise((res)=>{const p=spawn('curl',['-s','-o','/dev/null','-w','%{http_code}',url]);let out='';p.stdout.on('data',d=>out+=d);p.on('close',()=>res(out.trim()));});}
const SITE = process.env.CHECK_URL || "http://localhost:4000";
let bad = [];
for (const r of routes) {
  const code = await curl(SITE + r);
  if (!/^2\d\d$/.test(code)) bad.push({route:r,code});
}
if (bad.length){ console.error("Broken routes:", bad); process.exit(1); }
console.log("Links OK:", routes.join(", "));
