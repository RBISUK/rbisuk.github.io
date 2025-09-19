export const dynamic = "force-dynamic";
export const metadata = { title: "Verdiex Manager | RBIS" };

type FlowCard = { id: string; title: string; status: "active"|"paused"; steps: number; updatedAt: string; };

async function getFlows(): Promise<FlowCard[]> {
  // For now, a static list. Later: fetch from VERDIEX_FLOW_BASE or your DB.
  return [{ id: "hdr_v2", title: "Housing Disrepair Intake", status: "active", steps: 7, updatedAt: "today" }];
}

export default async function VerdiexManager() {
  const flows = await getFlows();
  return (
    <main className="container py-10">
      <h1 className="text-2xl font-bold">Verdiex Manager</h1>
      <p className="mt-2 text-neutral-600">Control flows, routing, webhooks, and SLAs.</p>
      <div className="mt-6 grid gap-4 sm:grid-cols-2">
        {flows.map(f => (
          <div key={f.id} className="card p-5">
            <div className="flex items-center justify-between">
              <h2 className="font-semibold">{f.title}</h2>
              <span className="text-xs px-2 py-1 rounded bg-neutral-100">{f.status}</span>
            </div>
            <p className="mt-1 text-sm text-neutral-600">{f.steps} steps • updated {f.updatedAt}</p>
            <div className="mt-4 flex gap-2">
              <a className="btn border border-neutral-300 hover:bg-neutral-100" href={`/api/veridex/start?flow=${f.id}`}>Preview</a>
              <a className="btn border border-neutral-300 hover:bg-neutral-100" href={`/veridex/analytics?flow=${f.id}`}>Analytics</a>
              <a className="btn border border-neutral-300 hover:bg-neutral-100" href="https://verdiex-console.example" target="_blank" rel="noreferrer">Open Console</a>
            </div>
          </div>
        ))}
      </div>
    </main>
  );
}
