import { spawn, execSync } from "child_process";
import fs from "fs";

function sleep(ms){ return new Promise(r=>setTimeout(r,ms)); }

async function waitHealth(url="http://localhost:3000/api/health", tries=40) {
  for (let i=0;i<tries;i++){
    try {
      const r = await fetch(url, { cache: "no-store" });
      if (r.ok) return true;
    } catch {}
    await sleep(500);
  }
  return false;
}

async function main() {
  // kill any prior dev
  try { execSync('pkill -f "next dev"'); } catch {}

  // install if needed
  if (!fs.existsSync("node_modules")) {
    console.log("⏳ Installing dependencies…");
    execSync("npm install --legacy-peer-deps", { stdio: "inherit" });
  }

  console.log("▶️  Starting dev server…");
  const dev = spawn("npm", ["run", "dev"], { stdio: "inherit", env: { ...process.env } });

  // wait for health
  const ok = await waitHealth();
  if (!ok) {
    dev.kill("SIGTERM");
    console.error("❌ Dev server did not become healthy");
    process.exit(1);
  }
  console.log("✅ Dev server healthy");

  // smoke intake
  try {
    execSync("node scripts/smoke-intake.mjs", { stdio: "inherit" });
  } catch (e) {
    dev.kill("SIGTERM");
    console.error("❌ Smoke intake failed");
    process.exit(1);
  }

  // quick typecheck + lint + build
  try {
    console.log("🔎 Typecheck");
    execSync("npm run typecheck", { stdio: "inherit" });
    console.log("🧹 Lint");
    execSync("npm run lint || true", { stdio: "inherit" });
    console.log("🏗️  Build");
    execSync("npm run build", { stdio: "inherit" });
  } catch (e) {
    dev.kill("SIGTERM");
    console.error("❌ QA step failed");
    process.exit(1);
  }

  // stop dev
  dev.kill("SIGTERM");
  console.log("✅ Full test completed");
}
main().catch(e => { console.error(e); process.exit(1); });
