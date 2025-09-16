export const metadata = {
  title: "RBIS — Main",
  description: "Behavioural & Intelligence Services",
};

export default function MainPage() {
  return (
    <main>
      {/* Hero Section */}
      <section className="bg-white py-24">
        <div className="container text-center">
          <h1 className="text-5xl font-bold text-slate-900">
            Behavioural & Intelligence
          </h1>
          <p className="mt-6 text-lg text-slate-600 max-w-2xl mx-auto">
            RBIS delivers compliance-ready AI, automation, and intelligence 
            systems designed to help housing providers, law firms, and 
            enterprises stay one step ahead.
          </p>
          <div className="mt-8 flex justify-center gap-4">
            <a href="/form" className="btn">Get Started</a>
            <a href="/hdr" className="btn bg-slate-700 hover:bg-slate-900">Explore HDR Funnel</a>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="bg-gray-50 py-16">
        <div className="container grid md:grid-cols-3 gap-8">
          <div className="card">
            <h3 className="text-xl font-semibold">Compliance First</h3>
            <p className="mt-2 text-slate-600">
              Every product is audit-ready with GDPR, FCA, and SRA safeguards built in.
            </p>
          </div>
          <div className="card">
            <h3 className="text-xl font-semibold">Automation Copilots</h3>
            <p className="mt-2 text-slate-600">
              From intake funnels to dashboards, we streamline workflows with precision.
            </p>
          </div>
          <div className="card">
            <h3 className="text-xl font-semibold">Trusted Insights</h3>
            <p className="mt-2 text-slate-600">
              Delivering intelligence dashboards and compliance alerts to protect your organisation.
            </p>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="bg-blue-600 text-white py-20">
        <div className="container text-center">
          <h2 className="text-3xl font-bold">Ready to transform compliance?</h2>
          <p className="mt-4 text-lg">
            Book a free consultation with RBIS today and see how we can help.
          </p>
          <a href="/form" className="btn mt-6">Book Consultation</a>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-900 text-white py-12">
        <div className="container text-center">
          <p className="text-sm">&copy; {new Date().getFullYear()} RBIS — Behavioural & Intelligence Services. All rights reserved.</p>
        </div>
      </footer>
    </main>
  );
}
