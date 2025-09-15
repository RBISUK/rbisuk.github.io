export const metadata = {
  title: "RBIS Intelligence — Behavioural & Intelligence Services",
  description: "Compliance-first, AI-native systems. Built to withstand audit and deliver outcomes.",
};
export default function Page() {
  return (
    <section className="space-y-8">
      <h1 className="text-4xl md:text-6xl font-extrabold tracking-tight">
        RBIS: Compliance-first. <span className="text-emerald-600">AI-native.</span> Always on.
      </h1>
      <p className="text-gray-600 max-w-2xl">
        Ryan Roberts’ behavioural & intelligence practice. We build funnels, automations, dashboards, and reporting
        that are court-ready, audit-safe, and fast.
      </p>
      <div className="flex gap-3">
        <a href="/main/trust" className="btn btn-primary">Trust & Assurance</a>
        <a href="/main/dashboards" className="btn btn-outline">Dashboards</a>
        <a href="/hdr" className="btn">See HDR Funnel</a>
      </div>
      <div className="grid md:grid-cols-3 gap-6 pt-8">
        <div className="card"><h3 className="font-semibold">Evidence-centric UX</h3><p>Chain-of-custody, citations, exportable logs.</p></div>
        <div className="card"><h3 className="font-semibold">Dual-method analysis</h3><p>AI surfaces patterns; humans make the calls.</p></div>
        <div className="card"><h3 className="font-semibold">SEO robots</h3><p>Content refreshers keep traffic compounding.</p></div>
      </div>
    </section>
  );
}
