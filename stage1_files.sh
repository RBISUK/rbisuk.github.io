set -e
cd /workspaces/rbisuk.github.io

mkdir -p app/components app/legal/dpia app/api/health scripts

# Cookie Banner
cat > app/components/CookieBanner.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";

export default function CookieBanner() {
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const consent = typeof window !== "undefined" ? localStorage.getItem("cookie-consent") : "accepted";
    if (!consent) setVisible(true);
  }, []);
  function accept() {
    localStorage.setItem("cookie-consent", "accepted");
    setVisible(false);
  }
  if (!visible) return null;
  return (
    <div className="fixed bottom-0 inset-x-0 bg-gray-900 text-white p-4 z-50 flex flex-col md:flex-row items-center justify-between">
      <p className="text-sm mb-2 md:mb-0">
        We use only necessary cookies. See our{" "}
        <a href="/legal/cookies" className="underline text-blue-300">Cookie Policy</a>.
      </p>
      <button onClick={accept} className="ml-4 bg-blue-600 text-white px-4 py-2 rounded">Accept</button>
    </div>
  );
}
TSX

# Scroll manager to prevent "jump to bottom" feel
cat > app/components/ScrollManager.tsx <<'TSX'
"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";

export default function ScrollManager() {
  const pathname = usePathname();
  useEffect(() => {
    // Scroll to top on route change and avoid focus jumps.
    window.requestAnimationFrame(() => window.scrollTo({ top: 0, behavior: "instant" as ScrollBehavior }));
  }, [pathname]);
  return null;
}
TSX

# Minimal, valid /form – compiles fast (we’ll style later)
mkdir -p app/form
cat > app/form/page.tsx <<'TSX'
"use client";
import { useState } from "react";
type Nav = { onNext: () => void; onBack?: () => void };

export default function FormPage() {
  const [step, setStep] = useState(1);
  const total = 5;
  return (
    <main className="min-h-[60vh] p-6 max-w-3xl mx-auto">
      <Progress step={step} total={total} />
      {step === 1 && <StepWelcome onNext={() => setStep(2)} />}
      {step === 2 && <StepEligibility onNext={() => setStep(3)} onBack={() => setStep(1)} />}
      {step === 3 && <StepDetails onNext={() => setStep(4)} onBack={() => setStep(2)} />}
      {step === 4 && <StepConsent onNext={() => setStep(5)} onBack={() => setStep(3)} />}
      {step === 5 && <StepSubmit onBack={() => setStep(4)} />}
      <p className="mt-4 text-sm text-gray-600 bg-gray-50 border rounded p-3">
        We comply with GDPR, never sell your data, and your form is reviewed by a trained human — not AI.
        Your rights are protected by law.
      </p>
    </main>
  );
}

function Progress({ step, total }: { step: number; total: number }) {
  const pct = Math.round((step / total) * 100);
  return (
    <div className="mb-6">
      <div className="flex justify-between text-sm text-gray-500">
        <span>Step {step} of {total}</span><span>{pct}%</span>
      </div>
      <div className="w-full h-2 bg-gray-200 rounded">
        <div className="h-2 bg-blue-600 rounded" style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

function StepWelcome({ onNext }: Nav) {
  return (
    <section>
      <h1 className="text-3xl font-bold">Start your housing disrepair check</h1>
      <p className="mt-3 text-gray-600">~3 minutes. Compliance checks + pre-eligibility, then evidence.</p>
      <button onClick={onNext} className="mt-6 px-5 py-3 rounded-xl bg-blue-600 text-white">Begin</button>
    </section>
  );
}
function StepEligibility({ onNext, onBack }: Nav) {
  return (
    <section>
      <h2 className="text-2xl font-semibold">Quick eligibility</h2>
      <div className="mt-4 grid gap-3">
        <label className="block">Are you a tenant in England or Wales?
          <select className="mt-1 block w-full border rounded-lg p-2"><option>Yes</option><option>No</option></select>
        </label>
        <label className="block">Who is your landlord?
          <select className="mt-1 block w-full border rounded-lg p-2">
            <option>Council</option><option>Housing Association</option><option>Private</option><option>Other</option>
          </select>
        </label>
      </div>
      <div className="mt-6 flex gap-3">
        <button onClick={onBack} className="px-4 py-2 rounded-lg border">Back</button>
        <button onClick={onNext} className="px-4 py-2 rounded-lg bg-blue-600 text-white">Continue</button>
      </div>
    </section>
  );
}
function StepDetails({ onNext, onBack }: Nav) {
  return (
    <section>
      <h2 className="text-2xl font-semibold">Issue details</h2>
      <div className="mt-4 grid gap-3">
        <label className="block">Main problem
          <select className="mt-1 block w-full border rounded-lg p-2">
            <option>Damp/Mould</option><option>Leaks</option><option>Heating</option>
            <option>Electrics</option><option>Pests</option><option>Other</option>
          </select>
        </label>
        <label className="block">How long has this been ongoing?
          <input type="text" className="mt-1 block w-full border rounded-lg p-2" placeholder="e.g., 6 months"/>
        </label>
      </div>
      <div className="mt-6 flex gap-3">
        <button onClick={onBack} className="px-4 py-2 rounded-lg border">Back</button>
        <button onClick={onNext} className="px-4 py-2 rounded-lg bg-blue-600 text-white">Continue</button>
      </div>
    </section>
  );
}
function StepConsent({ onNext, onBack }: Nav) {
  return (
    <section>
      <h2 className="text-2xl font-semibold">Consent</h2>
      <p className="text-sm text-gray-600">You can withdraw consent at any time. We do not automate decisions.</p>
      <div className="mt-4"><label className="inline-flex items-center gap-2">
        <input type="checkbox" className="scale-125" /> I consent to processing this information.
      </label></div>
      <div className="mt-6 flex gap-3">
        <button onClick={onBack} className="px-4 py-2 rounded-lg border">Back</button>
        <button onClick={onNext} className="px-4 py-2 rounded-lg bg-blue-600 text-white">Continue</button>
      </div>
    </section>
  );
}
function StepSubmit({ onBack }: Nav) {
  return (
    <section>
      <h2 className="text-2xl font-semibold">Submit</h2>
      <p className="text-sm text-gray-600">We’ll review and contact you. Average case value £800–£1,000 (not guaranteed).</p>
      <div className="mt-6 flex gap-3">
        <button onClick={onBack} className="px-4 py-2 rounded-lg border">Back</button>
        <button className="px-4 py-2 rounded-lg bg-green-600 text-white">Submit</button>
      </div>
    </section>
  );
}
TSX

# DPIA page
cat > app/legal/dpia/page.tsx <<'TSX'
export default function DPIA() {
  return (
    <main className="prose max-w-3xl mx-auto p-6">
      <h1>Data Protection Impact Assessment (Summary)</h1>
      <h2>Overview</h2>
      <p>This assesses data protection risks in the RBIS Intake Portal (e.g. housing, debt, health, PI).</p>
      <h2>Why It’s Needed</h2>
      <ul>
        <li>We may receive health/vulnerability data (GDPR Art. 9)</li>
        <li>Processing supports legal triage by a human</li>
        <li>We log submissions with metadata (time, browser, IP)</li>
      </ul>
      <h2>Mitigation Measures</h2>
      <ul>
        <li>Explicit consent for all processing</li>
        <li>No automated decisions</li>
        <li>Data minimisation by claim type</li>
        <li>Retention controls + anonymisation schedule</li>
        <li>HTTPS required; encrypted storage by processors</li>
      </ul>
      <h2>Risk Level</h2>
      <p>Low–moderate, mitigated by layered consent, transparency, and human review.</p>
      <h2>Contact</h2>
      <p>For the full DPIA, email dpo@rbis.uk</p>
    </main>
  );
}
TSX

# Health check endpoint
mkdir -p app/api/health
cat > app/api/health/route.ts <<'TS'
export async function GET() {
  return new Response(JSON.stringify({ ok: true, ts: Date.now() }), {
    headers: { "content-type": "application/json", "cache-control": "no-store" },
    status: 200,
  });
}
TS

# Next.js performance config (safe, production-oriented)
cat > next.config.mjs <<'MJS'
/** @type {import('next').NextConfig} */
const nextConfig = {
  poweredByHeader: false,
  compress: true,
  reactStrictMode: true,
  swcMinify: true,
  compiler: {
    removeConsole: process.env.NODE_ENV === "production" ? { exclude: ["error", "warn"] } : false,
  },
  images: {
    formats: ["image/avif", "image/webp"],
  },
  experimental: {
    // Helps reduce bundle for common libs
    optimizePackageImports: ["react", "react-dom"],
    // Prefetch check is a nice perf/bug safeguard
    strictNextHead: true,
  },
  async headers() {
    return [
      {
        source: "/_next/static/:path*",
        headers: [
          { key: "Cache-Control", value: "public, max-age=31536000, immutable" },
        ],
      },
      {
        source: "/fonts/:path*",
        headers: [
          { key: "Cache-Control", value: "public, max-age=31536000, immutable" },
        ],
      },
    ];
  },
};
export default nextConfig;
MJS

# smoke test script
cat > scripts/smoke.mjs <<'JS'
import fs from "node:fs";
const must = [
  "app/components/CookieBanner.tsx",
  "app/components/ScrollManager.tsx",
  "app/form/page.tsx",
  "app/legal/dpia/page.tsx",
  "app/api/health/route.ts",
  "next.config.mjs",
];
let ok = true;
for (const p of must) {
  if (fs.existsSync(p)) {
    console.log("✅ Found:", p);
  } else {
    ok = false;
    console.error("❌ Missing:", p);
  }
}
process.exit(ok ? 0 : 1);
JS

# Add or update npm scripts (safe, programmatic)
node - <<'NODE'
const fs = require('fs');
const pkgPath = 'package.json';
const pkg = JSON.parse(fs.readFileSync(pkgPath,'utf8'));
pkg.scripts ||= {};
pkg.scripts.dev ||= "next dev";
pkg.scripts.build ||= "next build";
pkg.scripts.start ||= "next start -p 3000";
pkg.scripts.smoke = "node scripts/smoke.mjs";
pkg.scripts.health = "curl -sS localhost:3000/api/health || true";
fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + "\n");
console.log("package.json scripts updated.");
NODE

echo "Stage 1 complete."
