export const metadata = {
  title: "HDR — Value",
  description: "Outcomes you get from the RBIS HDR Funnel.",
};

const bullets = [
  "Higher form completion rates & cleaner data",
  "Shorter response times via routing and webhooks",
  "Audit-ready logs for regulated environments",
  "Faster experiments with isolated funnels",
];

export default function Value() {
  return (
    <main className="py-16">
      <div className="container mx-auto px-6 max-w-3xl">
        <h1 className="text-4xl font-bold">Value</h1>
        <ul className="mt-6 space-y-3 text-slate-700">
          {bullets.map((b) => <li key={b}>• {b}</li>)}
        </ul>

        <a href="/form" className="mt-10 inline-flex items-center rounded-md bg-blue-600 px-5 py-3 text-white font-medium hover:bg-blue-700 transition">
          Book a Funnel Review
        </a>
      </div>
    </main>
  );
}
