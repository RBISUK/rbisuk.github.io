#!/usr/bin/env bash
set -euo pipefail

log() { printf "\n\033[1;34m▶ %s\033[0m\n" "$*"; }
fail() { printf "\n\033[1;31m✖ %s\033[0m\n" "$*"; exit 1; }

log "0) Ensure repo root and Node env"
[ -f package.json ] || fail "Run this from the repo root (package.json not found)."
command -v node >/dev/null || fail "Node not found."
command -v npm  >/dev/null || fail "npm not found."

log "1) Create required dirs"
mkdir -p app/hdr app/hdr/help app/api/veridex/start components/hdr verdiex/flows app/veridex

log "2) Remove App/Pages router conflict for /hdr"
if [ -f pages/hdr.tsx ]; then
  mkdir -p legacy_pages
  git mv -f pages/hdr.tsx legacy_pages/hdr.pages.tsx || mv pages/hdr.tsx legacy_pages/hdr.pages.tsx
  log "Moved pages/hdr.tsx -> legacy_pages/hdr.pages.tsx"
fi
if [ -d pages/hdr ]; then
  mkdir -p legacy_pages
  git mv -f pages/hdr legacy_pages/hdr.pages.bak || mv pages/hdr legacy_pages/hdr.pages.bak
  log "Moved pages/hdr -> legacy_pages/hdr.pages.bak"
fi

log "3) Write HDR header"
cat > components/hdr/HdrHeader.tsx <<'TSX'
"use client";
import Link from "next/link";
export default function HdrHeader() {
  return (
    <header className="border-b border-neutral-200 bg-white">
      <div className="container flex h-14 items-center justify-between">
        <Link href="/" className="flex items-center gap-2" aria-label="RBIS Home">
          <span className="font-bold tracking-tight">RBIS</span>
          <span className="hidden sm:inline text-sm text-neutral-600">Housing Disrepair</span>
        </Link>
        <nav className="flex items-center gap-4 text-sm">
          <Link href="/hdr/help" className="hover:underline">Help</Link>
          <Link href="/contact" className="hover:underline">Contact</Link>
        </nav>
      </div>
    </header>
  );
}
TSX

log "4) Write HDR layout"
cat > app/hdr/layout.tsx <<'TSX'
import HdrHeader from "@/components/hdr/HdrHeader";
import "../globals.css";
export const metadata = {
  title: "Report Housing Disrepair | RBIS",
  description: "Securely report disrepair and build an audit-ready evidence pack."
};
export default function HdrLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-neutral-50 text-neutral-900">
        <HdrHeader />
        <main className="container py-6">{children}</main>
      </body>
    </html>
  );
}
TSX

log "5) Write HDR landing (button-only -> Verdiex)"
cat > app/hdr/page.tsx <<'TSX'
import Link from "next/link";
export const metadata = {
  title: "Report Housing Disrepair | RBIS",
  description: "Log issues, add evidence, generate a landlord/Ombudsman-ready pack."
};
export default function HdrLanding() {
  return (
    <>
      <section className="pt-10">
        <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight">Report housing disrepair in minutes</h1>
        <p className="mt-3 text-neutral-700 max-w-2xl">
          Damp &amp; mould, leaks, heating, electrics, structural issues. Build a clear evidence timeline and a regulator-ready pack.
        </p>
        <div className="mt-6 flex flex-wrap gap-3">
          <a href="/api/veridex/start?flow=hdr_v2" className="btn-primary">Start Report</a>
          <Link href="/hdr/help" className="btn border border-neutral-300 hover:bg-neutral-100">What you’ll need</Link>
        </div>
        <p className="mt-3 text-xs text-neutral-600">
          Not legal advice. For emergencies, contact emergency services and your landlord immediately.
        </p>
      </section>
      <section className="mt-10 grid gap-4 sm:grid-cols-3">
        <div className="card p-5"><h3 className="font-semibold">Fast</h3><p className="text-sm text-neutral-700 mt-1">1 button to begin. Progress auto-saves.</p></div>
        <div className="card p-5"><h3 className="font-semibold">Evidence-first</h3><p className="text-sm text-neutral-700 mt-1">Photos/videos + dates build a reliable timeline.</p></div>
        <div className="card p-5"><h3 className="font-semibold">Audit-ready</h3><p className="text-sm text-neutral-700 mt-1">Exports for landlord or Ombudsman. Consent logged.</p></div>
      </section>
    </>
  );
}
TSX

log "6) Write HDR help"
cat > app/hdr/help/page.tsx <<'TSX'
export const metadata = { title: "HDR Help | RBIS" };
export default function HdrHelp() {
  return (
    <main className="container py-10">
      <h1 className="text-2xl font-bold">Help: Reporting Housing Disrepair</h1>
      <p className="mt-3 text-neutral-700 max-w-2xl">
        You can save and return. For emergencies, contact emergency services and your landlord immediately.
      </p>
      <h2 className="mt-6 font-semibold">Tips</h2>
      <ul className="mt-2 list-disc pl-5 space-y-1 text-neutral-800">
        <li>Take photos in good light; include context and detail shots.</li>
        <li>Note when it started and how it affects health or safety.</li>
        <li>Keep dates of reports, visits, and missed appointments.</li>
      </ul>
    </main>
  );
}
TSX

log "7) Verdiex start route (redirect to hosted Verdiex)"
cat > app/api/veridex/start/route.ts <<'TS'
import { NextResponse } from "next/server";
import crypto from "node:crypto";

const VERDIEX_BASE = process.env.VERDIEX_BASE_URL!;
const VERDIEX_API_KEY = process.env.VERDIEX_API_KEY!;
const ZAPIER_HOOK = process.env.ZAPIER_HOOK_URL || "";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const flow = searchParams.get("flow") || "hdr_v2";
  const sid = crypto.randomBytes(16).toString("hex");
  const payload = { sid, flow, ts: Date.now(), src: "rbis-intel-web" };
  const token = Buffer.from(JSON.stringify(payload)).toString("base64url");

  if (ZAPIER_HOOK) {
    fetch(ZAPIER_HOOK, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ event: "session_started", ...payload }) }).catch(()=>{});
  }
  const url = `${VERDIEX_BASE}/start?flow=${encodeURIComponent(flow)}&token=${token}&apikey=${VERDIEX_API_KEY}`;
  return NextResponse.redirect(url, 302);
}
TS

log "8) Minimal flow (doc/local fallback)"
cat > verdiex/flows/hdr_v2.json <<'JSON'
{
  "id": "hdr_v2",
  "title": "Housing Disrepair Intake",
  "steps": [
    { "id": "consent", "type": "consent", "text": "I agree to fair processing and terms", "required": true },
    { "id": "issue_type", "type": "single-select", "label": "What is the issue?", "options": ["Damp & mould","Leaks","Heating/hot water","Electrics","Structural"], "default": "Damp & mould" },
    { "id": "impact", "type": "textarea", "label": "How does this affect your household?" },
    { "id": "evidence", "type": "uploader", "label": "Add photos/videos", "accept": ["image/*","video/*"], "maxFiles": 10, "helper": "Wide shot + close-up; include date where possible." },
    { "id": "timeline", "type": "timeline", "label": "Key dates (reported, visits, missed appointments)" },
    { "id": "priority_electrical", "type": "info", "visibleIf": { "issue_type": "Electrics" }, "text": "Electrical faults are safety-critical. We will prioritise this route." },
    { "id": "health_route", "type": "survey", "visibleIfAny": [{ "issue_type": "Damp & mould" }, { "impact_contains": ["breathing","asthma","health","mould"] }], "questions": [
      { "id": "symptoms", "type": "multi-select", "label": "Any health symptoms?", "options": ["Breathing issues","Skin irritation","Headaches","Other/unsure"] },
      { "id": "vulnerable", "type": "single-select", "label": "Any vulnerable persons in the home?", "options": ["Child under 5","Elderly","Respiratory condition","None"] }
    ]},
    { "id": "summary", "type": "pack-preview", "outputs": ["ombudsman_pdf","landlord_pack"] }
  ],
  "branches": [
    { "when": { "issue_type": "Electrics" }, "goto": "priority_electrical" },
    { "whenAny": [{ "issue_type": "Damp & mould" }, { "impact_contains": ["health","breathing","asthma","mould"] }], "goto": "health_route" }
  ]
}
JSON

log "9) Ensure Tailwind utilities exist (safe if already present)"
mkdir -p app
if ! grep -q '@import "tailwindcss"' app/globals.css 2>/dev/null; then
cat > app/globals.css <<'CSS'
@import "tailwindcss";
html, body { height: 100%; }
a { text-underline-offset: 2px; }
.container { @apply mx-auto max-w-6xl px-4; }
.card { @apply rounded-2xl border border-neutral-200 bg-white shadow-sm; }
.btn { @apply inline-flex items-center justify-center rounded-lg px-5 py-3 font-medium; }
.btn-primary { @apply inline-flex items-center justify-center rounded-lg px-5 py-3 font-medium text-white bg-black hover:bg-neutral-800 focus:outline-none focus:ring-2 focus:ring-black/40; }
CSS
  log "Wrote app/globals.css"
else
  log "app/globals.css already imports tailwindcss"
fi

log "10) Root layout background (visual sanity)"
cat > app/layout.tsx <<'TSX'
import "./globals.css";
export const metadata = { title: "RBIS", description: "Live robots. Compliance-first systems." };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-dvh bg-[#f4f6ff] antialiased">{children}</body>
    </html>
  );
}
TSX

log "11) Build (show full error if it fails)"
set +e
npm run build
code=$?
set -e
if [ $code -ne 0 ]; then
  fail "Build failed. Scroll up for the first TS/Webpack error."
fi

log "12) Reminders for env on Vercel:"
echo "   VERDIEX_BASE_URL     e.g. https://funnel.verdiex.com"
echo "   VERDIEX_API_KEY      provided by Verdiex"
echo "   ZAPIER_HOOK_URL      (optional)"
echo
log "Done. Deploy with: vercel --yes && vercel --prod --yes"
