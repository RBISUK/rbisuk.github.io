export default function HomePage() {
  return (
    <div className="container pt-16">
      <section className="grid lg:grid-cols-2 gap-10 items-center">
        <div>
          <div className="badge">Housing Disrepair (HDR)</div>
          <h1 className="mt-3 text-4xl sm:text-5xl font-bold tracking-tight">
            Damp & mould aren’t “just life”. <br />
            They’re fixable — and you may be owed compensation.
          </h1>
          <p className="mt-5 text-gray-300 leading-relaxed">
            We help UK tenants (council, housing association, private) evidence issues and pursue fair outcomes.
            Your case is reviewed by a trained human — never AI — and your data is protected under UK law.
          </p>
          <div className="mt-7 flex gap-3">
            <a href="/form" className="btn btn-primary">Start your claim</a>
            <a href="/how" className="btn btn-ghost">How it works</a>
          </div>
          <ul className="mt-6 text-sm text-gray-400 space-y-1">
            <li>• No win, no fee partners available (subject to eligibility)</li>
            <li>• Typical issues: damp/mould, leaks, no heating, pests, unsafe electrics</li>
            <li>• Secure uploads for photos, videos, and repair history</li>
          </ul>
        </div>
        <div className="card p-6">
          <h3 className="font-semibold text-lg">What makes RBIS different?</h3>
          <ul className="mt-3 space-y-2 text-gray-300">
            <li>✓ Human triage. No automated rejections.</li>
            <li>✓ Clear next steps within 1–2 business days.</li>
            <li>✓ We never sell your data. Ever.</li>
          </ul>
          <a href="/faqs" className="mt-5 inline-block text-blue-400 hover:text-blue-300">Read FAQs →</a>
        </div>
      </section>

      <section className="mt-16 grid sm:grid-cols-3 gap-4">
        <div className="card p-5"><div className="font-semibold">Evidence-led</div><p className="text-gray-400 mt-1">Photos, dates, and impacts strengthen your claim.</p></div>
        <div className="card p-5"><div className="font-semibold">Transparent</div><p className="text-gray-400 mt-1">You’ll always know where things stand.</p></div>
        <div className="card p-5"><div className="font-semibold">Compliant</div><p className="text-gray-400 mt-1">GDPR & UK retention controls; audit log on submissions.</p></div>
      </section>

      <div className="mt-12">
        <a href="/form" className="btn btn-primary">Start claim</a>
      </div>
    </div>
  );
}
