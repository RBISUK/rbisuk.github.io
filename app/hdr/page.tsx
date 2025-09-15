export const metadata = {
  title: "Claim-Fix-AI: Intake at Super-Intelligence Speed",
  description: "One funnel. Every HDR pattern. Evidence in minutes. SEO that never sleeps.",
};
export default function Page() {
  return (
    <section className="space-y-8">
      <p className="text-sm text-gray-500">Housing Disrepair (HDR)</p>
      <h1 className="text-4xl md:text-6xl font-extrabold tracking-tight">
        Claim-Fix-AI: Intake at <span className="text-emerald-600">Super-Intelligence</span> speed
      </h1>
      <p className="text-gray-600 max-w-2xl">
        One funnel covers all HDR patterns, triages automatically, prompts for missing evidence, and
        builds a court-ready evidence pack within minutes — while SEO robots keep traffic flowing.
      </p>
      <div className="flex gap-3">
        <a href="/hdr/form" className="btn btn-primary">Start pilot</a>
        <a href="/hdr/dashboards" className="btn btn-outline">View live dashboards</a>
        <a href="/hdr/what-it-does" className="btn">How it works</a>
      </div>

      <div className="grid md:grid-cols-3 gap-6 pt-8">
        <div className="card">
          <h3 className="font-semibold">Dynamic intake</h3>
          <p>One form branches for damp/mould, leaks, heating, electrics, structure, pests, injury.</p>
        </div>
        <div className="card">
          <h3 className="font-semibold">Evidence in minutes</h3>
          <p>Severity scoring, duplicate detection, guided media prompts, plus auto pack build.</p>
        </div>
        <div className="card">
          <h3 className="font-semibold">Always-fresh SEO</h3>
          <p>Robots regenerate sitemaps/schema, expand topics, and keep the funnel discoverable.</p>
        </div>
      </div>
    </section>
  );
}
