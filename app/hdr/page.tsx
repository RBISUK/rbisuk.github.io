export const metadata = {
  title: "RBIS — HDR Funnel",
  description: "Behavioural & Intelligence marketing funnel for high-intent leads.",
};

export default function HDRHome() {
  return (
    <main>
      {/* Hero */}
      <section className="bg-white py-24">
        <div className="container mx-auto px-6 text-center">
          <h1 className="text-5xl font-bold text-slate-900">
            HDR Funnel — Behavioural & Intelligence
          </h1>
          <p className="mt-6 text-lg text-slate-600 max-w-2xl mx-auto">
            Purpose-built landing funnel to capture, qualify, and route high-intent leads.
            Privacy-safe, audit-ready, and fast.
          </p>
          <div className="mt-8 flex justify-center gap-4">
            <a href="/form" className="inline-flex items-center rounded-md bg-blue-600 px-5 py-3 text-white font-medium hover:bg-blue-700 transition">
              Start Your Funnel
            </a>
            <a href="/hdr/what-it-does" className="inline-flex items-center rounded-md border border-slate-300 px-5 py-3 font-medium text-slate-700 hover:bg-slate-50 transition">
              What it Does
            </a>
          </div>
        </div>
      </section>

      {/* Pillars */}
      <section className="bg-gray-50 py-16">
        <div className="container mx-auto px-6 grid md:grid-cols-3 gap-8">
          <div className="rounded-2xl bg-white p-6 shadow-sm">
            <h3 className="text-xl font-semibold">Compliance-Ready</h3>
            <p className="mt-2 text-slate-600">
              GDPR, DPA, and retention controls built-in with server-side validation.
            </p>
          </div>
          <div className="rounded-2xl bg-white p-6 shadow-sm">
            <h3 className="text-xl font-semibold">Lead Quality</h3>
            <p className="mt-2 text-slate-600">
              Progressive profiling, UTM capture, and smart routing to sales ops.
            </p>
          </div>
          <div className="rounded-2xl bg-white p-6 shadow-sm">
            <h3 className="text-xl font-semibold">Performance</h3>
            <p className="mt-2 text-slate-600">
              Optimised for Core Web Vitals with edge caching and static prerender.
            </p>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="bg-blue-600 text-white py-20">
        <div className="container mx-auto px-6 text-center">
          <h2 className="text-3xl font-bold">Turn traffic into qualified revenue</h2>
          <p className="mt-4 text-lg">
            Deploy the HDR funnel on your domain with end-to-end consent and logging.
          </p>
          <a href="/form" className="inline-flex items-center rounded-md bg-white px-5 py-3 font-medium text-blue-700 hover:bg-blue-50 transition mt-6">
            Book a Demo
          </a>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-900 text-white py-12">
        <div className="container mx-auto px-6 text-center">
          <p className="text-sm">&copy; {new Date().getFullYear()} RBIS — HDR Funnel.</p>
        </div>
      </footer>
    </main>
  );
}
