export default function HDRDashboards(){
  return (
    <section className="space-y-6">
      <h1 className="text-3xl font-bold">HDR Dashboards</h1>
      <div className="grid md:grid-cols-2 gap-5">
        <article className="card">
          <h3 className="font-semibold">Pipeline</h3>
          <ul className="text-sm mt-2 list-disc ml-5">
            <li>Started → Verified → Triaged → Evidence-Ready → Sent</li>
            <li>Active claims: 124</li>
            <li>Avg. time to evidence: 21m</li>
          </ul>
        </article>
        <article className="card">
          <h3 className="font-semibold">SLA Wall</h3>
          <ul className="text-sm mt-2 list-disc ml-5">
            <li>Breaching soon: 7</li>
            <li>Breached: 2 (actioned)</li>
          </ul>
        </article>
      </div>
    </section>
  );
}
