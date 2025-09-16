export const metadata = {
  title: "HDR — Trust & Compliance",
  description: "How RBIS builds trust into every funnel.",
};

export default function Trust() {
  return (
    <main className="py-16">
      <div className="container mx-auto px-6 max-w-4xl">
        <h1 className="text-4xl font-bold">Trust & Compliance</h1>
        <p className="mt-4 text-slate-600">
          RBIS ships with sane defaults: Strict-Transport-Security, no-sniff, referrer policy,
          and a CSP you can harden. APIs validate payloads and keep an append-only audit trail.
        </p>

        <div className="mt-8 grid md:grid-cols-2 gap-6">
          <div className="rounded-2xl bg-white p-6 shadow-sm border">
            <h3 className="font-semibold">Data Minimisation</h3>
            <p className="mt-2 text-slate-600">Only collect what you need; easy redaction/export.</p>
          </div>
          <div className="rounded-2xl bg-white p-6 shadow-sm border">
            <h3 className="font-semibold">Retention Controls</h3>
            <p className="mt-2 text-slate-600">Rotate JSONL, export CSV for DSRs, and purge on policy.</p>
          </div>
        </div>

        <div className="mt-10">
          <a href="/legal" className="inline-flex items-center rounded-md border border-slate-300 px-4 py-2 font-medium text-slate-700 hover:bg-slate-50 transition">
            View Legal Pages
          </a>
        </div>
      </div>
    </main>
  );
}
