export const metadata = {
  title: "HDR — What it Does",
  description: "How the RBIS HDR Funnel works.",
};

export default function WhatItDoes() {
  return (
    <main className="py-16">
      <div className="container mx-auto px-6 max-w-4xl">
        <h1 className="text-4xl font-bold">What it Does</h1>
        <p className="mt-6 text-slate-600">
          The HDR Funnel orchestrates consent-compliant intake, progressive profiling,
          and qualification scoring. Each submission is validated server-side, logged to
          append-only JSONL, and optionally posted to your CRM or webhook.
        </p>

        <div className="mt-10 grid md:grid-cols-2 gap-6">
          <div className="rounded-2xl bg-white p-6 shadow-sm border">
            <h3 className="font-semibold">Intake & UTM</h3>
            <p className="mt-2 text-slate-600">
              Captures UTM parameters, consent, and contact data with pattern checks.
            </p>
          </div>
          <div className="rounded-2xl bg-white p-6 shadow-sm border">
            <h3 className="font-semibold">Routing</h3>
            <p className="mt-2 text-slate-600">
              Sends to /api/lead with structured payloads; webhooks for downstream CRMs.
            </p>
          </div>
          <div className="rounded-2xl bg-white p-6 shadow-sm border">
            <h3 className="font-semibold">Audit Trail</h3>
            <p className="mt-2 text-slate-600">
              JSONL logs + optional nightly rotation and CSV exports for audits.
            </p>
          </div>
          <div className="rounded-2xl bg-white p-6 shadow-sm border">
            <h3 className="font-semibold">Performance</h3>
            <p className="mt-2 text-slate-600">
              Prerendered pages, shared JS under 110KB first load, and fast TTFB.
            </p>
          </div>
        </div>

        <div className="mt-10">
          <a href="/form" className="inline-flex items-center rounded-md bg-blue-600 px-5 py-3 text-white font-medium hover:bg-blue-700 transition">
            Try the Intake Form
          </a>
        </div>
      </div>
    </main>
  );
}
