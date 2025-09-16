// app/main/page.tsx
export default function RBISMain() {
  return (
    <section className="py-16">
      <div className="grid gap-10">
        <div className="text-center">
          <h1 className="text-4xl font-bold tracking-tight">
            RBIS — Repairs & Compliance Copilot
          </h1>
          <p className="mt-4 text-lg text-slate-700">
            Audit-ready AI for housing providers: tenant repair intake,
            compliance timers, automated comms, and court-ready evidence packs.
          </p>
          <div className="mt-6 flex justify-center gap-3">
            <a
              href="#contact"
              className="rounded-xl border px-5 py-2.5 text-sm font-medium hover:bg-slate-50"
            >
              Book a demo
            </a>
            <a
              href="#products"
              className="rounded-xl bg-black px-5 py-2.5 text-sm font-medium text-white hover:opacity-90"
            >
              Explore products
            </a>
          </div>
        </div>

        <div id="products" className="grid gap-6 md:grid-cols-2">
          <div className="rounded-2xl border p-6 shadow-sm">
            <h2 className="text-xl font-semibold">Claim-Fix-AI (HDR Funnel)</h2>
            <p className="mt-2 text-sm text-slate-700">
              Intake funnel for housing disrepair: captures evidence, validates issues,
              sets SLA timers, and generates exportable packs.
            </p>
            <a className="mt-3 inline-block text-sm underline" href="/claim-fix-ai">
              View details →
            </a>
          </div>

          <div className="rounded-2xl border p-6 shadow-sm">
            <h2 className="text-xl font-semibold">RBIS OmniAssist</h2>
            <p className="mt-2 text-sm text-slate-700">
              Modular automation assistant for repetitive workflows with guardrails
              and compliance overlays.
            </p>
            <a className="mt-3 inline-block text-sm underline" href="/omniassist">
              View details →
            </a>
          </div>

          <div className="rounded-2xl border p-6 shadow-sm">
            <h2 className="text-xl font-semibold">RBIS Dashboard</h2>
            <p className="mt-2 text-sm text-slate-700">
              Executive insights, compliance alerts, and KPI rollups.
            </p>
            <a className="mt-3 inline-block text-sm underline" href="/dashboard">
              View details →
            </a>
          </div>

          <div className="rounded-2xl border p-6 shadow-sm">
            <h2 className="text-xl font-semibold">NextusOne CRM</h2>
            <p className="mt-2 text-sm text-slate-700">
              AI-native CRM with GDPR/FCA/SRA overlays and audit trails.
            </p>
            <a className="mt-3 inline-block text-sm underline" href="/nextusone">
              View details →
            </a>
          </div>
        </div>

        <div id="pricing" className="rounded-2xl border p-6 shadow-sm">
          <h2 className="text-xl font-semibold">Pricing</h2>
          <ul className="mt-3 list-disc pl-6 text-sm text-slate-700">
            <li>Starter: core intake + basic exports</li>
            <li>Pro: SLA timers, automated comms, advanced exports</li>
            <li>Enterprise: multi-tenant, RBAC, custom compliance overlays</li>
          </ul>
          <p className="mt-3 text-sm text-slate-600">
            Full pricing available on request while we onboard pilot partners.
          </p>
        </div>

        <div id="contact" className="rounded-2xl border p-6 shadow-sm">
          <h2 className="text-xl font-semibold">Contact</h2>
          <p className="mt-2 text-sm text-slate-700">
            Ready to trial the Repairs & Compliance Copilot?
          </p>
          <a className="mt-3 inline-block text-sm underline" href="mailto:hello@rbisintelligence.com">
            hello@rbisintelligence.com
          </a>
        </div>
      </div>
    </section>
  );
}
