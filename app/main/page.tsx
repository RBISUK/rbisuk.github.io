export default function RBISHome(){
  return (
    <section className="space-y-6">
      <h1 className="text-4xl font-bold">RBIS Intelligence — Behavioural & Compliance-first</h1>
      <p className="text-slate-600 max-w-3xl">
        Human behavioural insights, court-ready reporting, and compliant automations. AI assists; humans decide.
      </p>
      <div className="flex gap-3">
        <a href="/main/dashboards" className="btn">View Dashboards</a>
        <a href="/main/trust" className="rounded-md border px-4 py-2">Trust Centre</a>
        <a href="/main/contact" className="rounded-md border px-4 py-2">Contact</a>
      </div>
    </section>
  );
}
