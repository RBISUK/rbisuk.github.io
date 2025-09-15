export const metadata = {
  title: "Dashboards — RBIS",
  description: "Behavioural signals, operational flow, and live evidentiary states.",
};
const Stat = ({label, value}:{label:string; value:string}) => (
  <div className="p-4 rounded-lg border bg-white"><div className="text-xs text-gray-500">{label}</div><div className="text-2xl font-bold">{value}</div></div>
);
export default function Page() {
  return (
    <section className="space-y-8">
      <h1 className="text-3xl font-bold">RBIS Dashboards</h1>
      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Stat label="Signals tracked" value="58" />
        <Stat label="Median cycle time" value="2.4d" />
        <Stat label="Exportable reports" value="12" />
        <Stat label="SEO health" value="1000" />
      </div>
      <div className="card"><h3 className="font-semibold">Evidence trace</h3><p>View-only chain-of-custody timelines for any export.</p></div>
      <div className="card"><h3 className="font-semibold">Ops × Evidence</h3><p>Toggle between operational KPIs and evidentiary states.</p></div>
    </section>
  );
}
