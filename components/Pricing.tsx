export default function Pricing() {
  return (
    <section className="py-16 bg-gray-50">
      <div className="max-w-5xl mx-auto text-center">
        <h2 className="text-3xl font-bold mb-8">Pricing Plans</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="p-6 border rounded-lg shadow bg-white">
            <h3 className="font-semibold text-xl mb-4">Starter</h3>
            <p className="text-2xl font-bold mb-4">£99/mo</p>
            <ul className="mb-6 text-sm text-gray-600">
              <li>✔ Compliance-ready pages</li>
              <li>✔ Lead capture forms</li>
              <li>✔ Basic analytics</li>
            </ul>
          </div>
          <div className="p-6 border rounded-lg shadow bg-white">
            <h3 className="font-semibold text-xl mb-4">Pro</h3>
            <p className="text-2xl font-bold mb-4">£299/mo</p>
            <ul className="mb-6 text-sm text-gray-600">
              <li>✔ All Starter features</li>
              <li>✔ Automation add-ons</li>
              <li>✔ Priority support</li>
            </ul>
          </div>
          <div className="p-6 border rounded-lg shadow bg-white">
            <h3 className="font-semibold text-xl mb-4">Enterprise</h3>
            <p className="text-2xl font-bold mb-4">Custom</p>
            <ul className="mb-6 text-sm text-gray-600">
              <li>✔ Custom integrations</li>
              <li>✔ Dedicated consultant</li>
              <li>✔ SLA-backed uptime</li>
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}
