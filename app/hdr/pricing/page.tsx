export const metadata = {
  title: "HDR — Pricing",
  description: "Transparent pricing for the RBIS HDR Funnel.",
};

const tiers = [
  { name: "Starter", price: "£0/mo", features: ["Static HDR pages", "Email lead delivery", "Basic consent capture"] },
  { name: "Growth", price: "£299/mo", features: ["Webhook & CRM sync", "JSONL logging & rotation", "Custom domains & GA4"] },
  { name: "Scale", price: "£899/mo", features: ["Priority SLAs", "Custom scoring logic", "Multi-region deployments"] },
];

export default function Pricing() {
  return (
    <main className="py-16">
      <div className="container mx-auto px-6 text-center">
        <h1 className="text-4xl font-bold">Pricing</h1>
        <p className="mt-4 text-slate-600 max-w-2xl mx-auto">
          Pick the plan that matches your funnel maturity. All plans include compliance-ready defaults.
        </p>

        <div className="mt-10 grid md:grid-cols-3 gap-6">
          {tiers.map((t) => (
            <div key={t.name} className="rounded-2xl bg-white p-6 shadow-sm border text-left">
              <h3 className="text-xl font-semibold">{t.name}</h3>
              <p className="mt-2 text-3xl font-bold">{t.price}</p>
              <ul className="mt-4 space-y-2 text-slate-600">
                {t.features.map((f) => <li key={f}>• {f}</li>)}
              </ul>
              <a href="/form" className="mt-6 inline-flex items-center rounded-md bg-blue-600 px-4 py-2 text-white font-medium hover:bg-blue-700 transition">
                Choose {t.name}
              </a>
            </div>
          ))}
        </div>
      </div>
    </main>
  );
}
