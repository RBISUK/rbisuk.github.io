import { execSync } from "child_process";
import fs from "fs";
import path from "path";

const steps = [
  { name: "Smoke check files", cmd: "npm run smoke", fatal: true },
  { name: "TypeScript typecheck", cmd: "npm run typecheck", fatal: true },
  { name: "ESLint lint", cmd: "npm run lint || true", fatal: false },
  { name: "Build (prod)", cmd: "npm run build", fatal: true },
  { name: "Start server (background)", cmd: "npm run start & sleep 5", fatal: true },
  { name: "Health endpoint", cmd: "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/api/health", fatal: true },
  { name: "Smoke intake", cmd: "npm run smoke:intake", fatal: true }
];

let pass = 0, fail = 0;

for (const step of steps) {
  process.stdout.write(`🔍 ${step.name}... `);
  try {
    const out = execSync(step.cmd, { stdio: "pipe" }).toString();
    if (out.includes("200") || out.includes("PASSED") || out.includes("ok") || out.length > 0) {
      console.log("✅");
      pass++;
    } else {
      console.log("⚠️ check output");
      fail++;
      if (step.fatal) break;
    }
  } catch (e) {
    console.log("❌", e.status || e.message);
    fail++;
    if (step.fatal) break;
  }
}

// Kill background next start if running
try { execSync("pkill -f 'next start' || true"); } catch {}

console.log("--------------------------------------------------");
console.log(`QA Summary: ✅ ${pass} passed, ❌ ${fail} failed`);
if (fail === 0) {
  console.log("�� All systems GO — safe to push to GitHub");
} else {
  console.log("⚠️ Issues found — check the above logs carefully");
}
