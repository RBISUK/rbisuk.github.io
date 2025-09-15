import fs from "fs";
const needed = [
  "app/form/page.tsx",
  "app/api/submit/route.ts",
  "app/api/health/route.ts",
  "app/thank-you/page.tsx",
  "next.config.mjs"
];
let ok = true;
for (const f of needed) {
  if (!fs.existsSync(f)) { console.error("❌ Missing:", f); ok = false; }
  else console.log("✅ Found:", f);
}
process.exit(ok ? 0 : 1);
