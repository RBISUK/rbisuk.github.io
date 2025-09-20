#!/usr/bin/env bash
set -euo pipefail
log(){ printf "\n\033[1;34m▶ %s\033[0m\n" "$*"; }
fail(){ printf "\n\033[1;31m✖ %s\033[0m\n" "$*"; exit 1; }

[ -f package.json ] || fail "Run at the repo root."

log "A) Host-based rewrite so hdr.rbisintelligence.com → /hdr"
jq -n '
{
  version: 2,
  framework: "nextjs",
  crons: [{ path: "/api/ping-sitemap", schedule: "0 3 * * *" }],
  headers: [
    { source: "/(.*)", headers: [
      { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" },
      { key: "X-Content-Type-Options", value: "nosniff" },
      { key: "X-Frame-Options", value: "DENY" },
      { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" }
    ]}
  ],
  rewrites: [
    {
      "source": "/",
      "has": [{ "type": "host", "value": "hdr.rbisintelligence.com" }],
      "destination": "/hdr"
    }
  ],
  ignoreCommand: "echo prebuilt by Next"
}' > vercel.json

log "B) Global header (main site) with proper nav"
mkdir -p components
cat > components/SiteHeader.tsx <<'TSX'
"use client";
import Link from "next/link";

export default function SiteHeader() {
  return (
    <header className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-neutral-200">
      <div className="container flex h-14 items-center justify-between">
        <Link href="/" className="font-bold tracking-tight" aria-label="RBIS Home">
          RBIS
        </Link>
        <nav className="hidden sm:flex items-center gap-5 text-sm">
          <Link className="hover:underline" href="/products">Products</Link>
          <Link className="hover:underline" href="/services">Services</Link>
          <Link className="hover:underline" href="/reports">Reports</Link>
          <Link className="hover:underline" href="/dashboard">Dashboard</Link>
          <Link className="rounded-lg px-3 py-1.5 bg-black text-white hover:bg-neutral-800" href="/contact">Contact</Link>
        </nav>
        <div className="sm:hidden">
          <Link className="rounded-lg px-3 py-1.5 bg-black text-white" href="/contact">Contact</Link>
        </div>
      </div>
    </header>
  );
}
TSX

log "C) Ensure Root Layout uses the SiteHeader"
mkdir -p app
cat > app/layout.tsx <<'TSX'
import "./globals.css";
import SiteHeader from "@/components/SiteHeader";

export const metadata = { title: "RBIS", description: "Live robots. Compliance-first systems." };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-dvh bg-[#f4f6ff] text-neutral-900 antialiased">
        <SiteHeader />
        <main>{children}</main>
      </body>
    </html>
  );
}
TSX

log "D) Services & Reports pages (so nav isn’t dead)"
mkdir -p app/services app/reports
cat > app/services/page.tsx <<'TSX'
export const metadata = { title: "Services | RBIS" };
export default function Services() {
  return (
    <section className="container py-10">
      <h1 className="text-3xl font-bold">Services</h1>
      <p className="mt-3 max-w-2xl text-neutral-700">
        White-label websites, AI funnels, compliance overlays, data engineering, CRO experiments, and secure integrations.
      </p>
      <div className="grid mt-6 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div className="card p-5"><h3 className="font-semibold">Express 24h Build</h3><p className="text-sm text-neutral-700 mt-1">One-day brand + funnel + deploy.</p></div>
        <div className="card p-5"><h3 className="font-semibold">Compliance Overlays</h3><p className="text-sm text-neutral-700 mt-1">GDPR, ASA, FCA, SRA guardrails.</p></div>
        <div className="card p-5"><h3 className="font-semibold">SEO-AI & CRO</h3><p className="text-sm text-neutral-700 mt-1">Search + conversion optimisation that survives audits.</p></div>
      </div>
    </section>
  );
}
TSX

cat > app/reports/page.tsx <<'TSX'
export const metadata = { title: "Reports | RBIS" };
export default function Reports() {
  return (
    <section className="container py-10">
      <h1 className="text-3xl font-bold">Reports & Evidence</h1>
      <p className="mt-3 max-w-2xl text-neutral-700">
        Export regulator-ready packs: SLAs, timelines, event logs, and Verdiex journey transcripts with consent proofs.
      </p>
      <ul className="mt-6 space-y-2 text-neutral-800">
        <li>• Ombudsman pack (PDF)</li>
        <li>• Landlord/Provider pack (PDF + CSV)</li>
        <li>• Journey transcript with redactions (JSONL)</li>
      </ul>
    </section>
  );
}
TSX

log "E) HDR layout + header (dedicated)"
mkdir -p components/hdr app/hdr app/hdr/help
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

cat > app/hdr/layout.tsx <<'TSX'
import "../globals.css";
import HdrHeader from "@/components/hdr/HdrHeader";

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

log "F) HDR landing that applies Fogg + Hick"
cat > app/hdr/page.tsx <<'TSX'
import Link from "next/link";

export const metadata = {
  title: "Report Housing Disrepair | RBIS",
  description: "Log issues, add evidence, generate a landlord/Ombudsman-ready pack."
};

export default function HdrLanding() {
  return (
    <>
      {/* Fogg: Motivation */}
      <section className="pt-10">
        <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight">Report housing disrepair in minutes</h1>
        <p className="mt-3 text-neutral-700 max-w-2xl">
          Damp &amp; mould, leaks, heating, electrics, structural issues. Build a clear evidence timeline and a regulator-ready pack.
        </p>

        {/* Hick: one clear primary action */}
        <div className="mt-6 flex flex-wrap gap-3">
          <a href="/api/veridex/start?flow=hdr_v2" className="btn-primary">Start Report</a>
          <Link href="/hdr/help" className="btn border border-neutral-300 hover:bg-neutral-100">What you’ll need</Link>
        </div>

        <p className="mt-3 text-xs text-neutral-600">
          Not legal advice. For emergencies, contact emergency services and your landlord immediately.
        </p>
      </section>

      {/* Ability: show low effort + guidance */}
      <section className="mt-10 grid gap-4 sm:grid-cols-3">
        <div className="card p-5">
          <h3 className="font-semibold">Takes ~5–8 mins</h3>
          <p className="text-sm text-neutral-700 mt-1">Auto-saves progress. You can return anytime.</p>
        </div>
        <div className="card p-5">
          <h3 className="font-semibold">Evidence-first</h3>
          <p className="text-sm text-neutral-700 mt-1">Photos/videos + dates build a reliable timeline.</p>
        </div>
        <div className="card p-5">
          <h3 className="font-semibold">Audit-ready</h3>
          <p className="text-sm text-neutral-700 mt-1">Exports for landlord or Ombudsman. Consent logged.</p>
        </div>
      </section>

      {/* Trust & Accessibility */}
      <section aria-labelledby="trust" className="mt-10">
        <h2 id="trust" className="text-xl font-bold">Trust & Accessibility</h2>
        <ul className="mt-3 space-y-2 text-sm text-neutral-800">
          <li>• WCAG-friendly colours, keyboard navigable.</li>
          <li>• Plain-English prompts; optional large text mode.</li>
          <li>• Data encrypted in transit; minimal retention.</li>
        </ul>
      </section>
    </>
  );
}
TSX

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

log "G) Ensure Tailwind utilities exist (btn, card, container)"
mkdir -p app
if ! grep -q '@import "tailwindcss"' app/globals.css 2>/dev/null; then
  cat > app/globals.css <<'CSS'
@import "tailwindcss";
/* Base utilities used across site */
html, body { height: 100%; }
a { text-underline-offset: 2px; }
.container { @apply mx-auto max-w-6xl px-4; }
.card { @apply rounded-2xl border border-neutral-200 bg-white shadow-sm; }
.btn { @apply inline-flex items-center justify-center rounded-lg px-5 py-3 font-medium; }
.btn-primary { @apply inline-flex items-center justify-center rounded-lg px-5 py-3 font-medium text-white bg-black hover:bg-neutral-800 focus:outline-none focus:ring-2 focus:ring-black/40; }
CSS
fi

log "H) Remove any old conflicting Pages Router HDR or Veridex pages"
mkdir -p legacy_pages
[ -f pages/hdr.tsx ] && git mv -f pages/hdr.tsx legacy_pages/hdr.pages.tsx || true
[ -d pages/hdr ] && git mv -f pages/hdr legacy_pages/hdr.pages.bak || true
[ -f pages/veridex.tsx ] && git mv -f pages/veridex.tsx legacy_pages/veridex.pages.tsx || true
[ -f app/veridex/page.tsx ] && git rm -f app/veridex/page.tsx || true
[ -d app/veridex ] && rmdir app/veridex 2>/dev/null || true

log "I) Build"
npm run build

log "J) Commit (optional)"
git add -A && (git diff --cached --quiet || git commit -m "feat: proper nav, HDR landing, host rewrite for hdr subdomain") || true

log "K) Deploy preview then prod"
vercel --yes
vercel --prod --yes

log "L) Quick live checks (adjust domain if needed)"
echo
echo "Main HTML sanity (classes + nav):"
curl -s https://rbisintelligence.com | head -n 40 | egrep -n "SiteHeader|Products|Services|Reports|Dashboard|class="
echo
echo "HDR (subdomain) should land on /hdr:"
curl -s https://rbisintelligence.com/hdr | egrep -n "Report housing disrepair|Start Report|btn-primary|card"
echo
echo "API redirect (expect 302 → VERDIEX_BASE_URL):"
curl -I "https://rbisintelligence.com/api/veridex/start?flow=hdr_v2" | sed -n '1,10p'
