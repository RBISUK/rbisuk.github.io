import Link from "next/link";
export const metadata = {
  title: "Report Housing Disrepair | RBIS",
  description: "Log issues, add evidence, generate a landlord/Ombudsman-ready pack."
};
export default function HdrLanding() {
  return (
    <>
      <section className="pt-10">
        <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight">Report housing disrepair in minutes</h1>
        <p className="mt-3 text-neutral-700 max-w-2xl">
          Damp &amp; mould, leaks, heating, electrics, structural issues. Build a clear evidence timeline and a regulator-ready pack.
        </p>
        <div className="mt-6 flex flex-wrap gap-3">
          <a href="/api/veridex/start?flow=hdr_v2" className="btn-primary">Start Report</a>
          <Link href="/hdr/help" className="btn border border-neutral-300 hover:bg-neutral-100">What you’ll need</Link>
        </div>
        <p className="mt-3 text-xs text-neutral-600">
          Not legal advice. For emergencies, contact emergency services and your landlord immediately.
        </p>
      </section>
      <section className="mt-10 grid gap-4 sm:grid-cols-3">
        <div className="card p-5"><h3 className="font-semibold">Fast</h3><p className="text-sm text-neutral-700 mt-1">1 button to begin. Progress auto-saves.</p></div>
        <div className="card p-5"><h3 className="font-semibold">Evidence-first</h3><p className="text-sm text-neutral-700 mt-1">Photos/videos + dates build a reliable timeline.</p></div>
        <div className="card p-5"><h3 className="font-semibold">Audit-ready</h3><p className="text-sm text-neutral-700 mt-1">Exports for landlord or Ombudsman. Consent logged.</p></div>
      </section>
    </>
  );
}
