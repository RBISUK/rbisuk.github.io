export const metadata = {
  title: "Dashboards — HDR",
  description: "Pipeline, evidence readiness, SLA wall, handler load, SEO board.",
};
const Stat = ({label, value}:{label:string; value:string}) => (
  <div className="p-4 rounded-lg border bg-white"><div className="text-xs text-gray-500">{label}</div><div className="text-2xl font-bold">{value}</div></div>
);
export default function Page() {
  return (
    <section className="space-y-8">
      <h1 className="text-3xl font-bold">HDR Dashboards</h1>
      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Stat label="Active claims" value="124" />
        <Stat label="Avg. evidence time" value="18m" />
        <Stat label="Breaching soon" value="7" />
        <Stat label="Top issue" value="Damp & Mould" />
      </div>
      <div className="card">
        <h3 className="font-semibold">Pipeline</h3>
        <p>Started → Verified → Triaged → Evidence-Ready → Sent</p>
      </div>
      <div className="grid md:grid-cols-2 gap-4">
        <div className="card"><h3 className="font-semibold">Evidence readiness</h3><p>Missing exhibits, weak evidence, duplicate suspects.</p></div>
        <div className="card"><h3 className="font-semibold">SLA wall</h3><p>Time to landlord response, breaching soon, breached, actioned.</p></div>
      </div>
    </section>
  );
}
