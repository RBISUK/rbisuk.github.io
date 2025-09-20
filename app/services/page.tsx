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
