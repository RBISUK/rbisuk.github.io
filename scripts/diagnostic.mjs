import fs from "node:fs";
import { execSync } from "node:child_process";

const checks = {
  "CookieBanner": "app/components/CookieBanner.tsx",
  "ScrollManager": "app/components/ScrollManager.tsx",
  "Form Intake": "app/form/page.tsx",
  "DPIA": "app/legal/dpia/page.tsx",
  "Privacy": "app/legal/privacy/page.tsx",
  "Terms": "app/legal/terms/page.tsx",
  "Cookies": "app/legal/cookies/page.tsx",
  "API Health": "app/api/health/route.ts",
  "Config": "next.config.mjs",
};

let passed = 0;
let total = Object.keys(checks).length;

console.log("=== RBIS Health & Compliance Diagnostic ===");

for (const [label, path] of Object.entries(checks)) {
  if (fs.existsSync(path)) {
    console.log(`✅ ${label}: ${path}`);
    passed++;
  } else {
    console.log(`❌ ${label}: MISSING (${path})`);
  }
}

console.log("\n=== Build Test ===");
try {
  execSync("next build", { stdio: "ignore" });
  console.log("✅ Build passed");
  passed++;
  total++;
} catch {
  console.log("❌ Build failed");
  total++;
}

console.log("\n=== Score ===");
const score = Math.round((passed / total) * 100);
console.log(`${passed}/${total} checks passed → Health Score: ${score}/100`);

process.exit(score === 100 ? 0 : 1);
