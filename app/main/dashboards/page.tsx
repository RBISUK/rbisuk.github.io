export default function RBISDashboards(){
  return (
    <section className="space-y-6">
      <h1 className="text-3xl font-bold">RBIS Dashboards</h1>
      <div className="grid md:grid-cols-2 gap-5">
        <article className="card"><h3 className="font-semibold">Ops + Evidence Trace</h3>
          <ul className="list-disc ml-5 text-sm mt-2"><li>Decisions this week: 58</li><li>Redactions: 12</li></ul>
        </article>
        <article className="card"><h3 className="font-semibold">SEO Board</h3>
          <ul className="list-disc ml-5 text-sm mt-2"><li>Top cluster: “black mould asthma claim”</li><li>Weekly delta: +12%</li></ul>
        </article>
      </div>
    </section>
  );
}
