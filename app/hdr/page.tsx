export default function HDRHome(){
  return (
    <section className="space-y-6">
      <p className="uppercase text-xs tracking-wide text-slate-500">Housing Disrepair (HDR)</p>
      <h1 className="text-4xl font-bold">Claim-Fix-AI: Intake at Super-Intelligence Speed</h1>
      <p className="text-slate-600 max-w-3xl">
        One funnel. Every HDR pattern. Evidence out in minutes. SEO that never sleeps.
      </p>
      <div className="flex gap-3">
        <a href="/hdr/contact" className="btn">Start pilot</a>
        <a href="/hdr/dashboards" className="rounded-md border px-4 py-2">View live intake</a>
        <a href="/hdr/pricing" className="rounded-md border px-4 py-2">Pricing</a>
      </div>
      <div className="grid md:grid-cols-3 gap-5">
        <article className="card">
          <h3 className="font-semibold">What it does</h3>
          <ul className="list-disc ml-5 text-sm mt-2">
            <li>Triage + severity scoring</li><li>Evidence pack (PDF/ZIP+JSON)</li><li>SLA timers + letters</li>
          </ul>
        </article>
        <article className="card">
          <h3 className="font-semibold">Dynamic claim types</h3>
          <p className="text-sm mt-2">Damp/Mould • Leaks • Boiler • Electrics • Structure • Infestation • Injury</p>
        </article>
        <article className="card">
          <h3 className="font-semibold">Compliance defaults</h3>
          <p className="text-sm mt-2">Consent ledger • PECR comms • Art. 9(2)(f) where needed • Audit logs</p>
        </article>
      </div>
    </section>
  );
}
