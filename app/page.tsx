'use client';

import { motion } from 'framer-motion';
import SpinningCube from '../components/SpinningCube';
import Link from 'next/link';

export default function Home() {
  return (
    <div className="space-y-24">
      <section className="text-center bg-gradient-to-r from-green-400 to-blue-500 text-white py-24 px-4">
        <motion.h1
          className="text-5xl font-bold"
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          RBIS UK Behavioural & Intelligence Services
        </motion.h1>
        <p className="mt-6 text-xl max-w-2xl mx-auto">
          Independent Insight. Evidence-Based Decisions. Trusted Support.
        </p>
        <div className="mt-10 flex justify-center">
          <SpinningCube />
        </div>
      </section>

      <section id="regulatory" className="max-w-4xl mx-auto px-4">
        <h2 className="text-3xl font-semibold mb-4">Regulatory Notice</h2>
        <p className="bg-red-100 text-red-900 p-4 rounded">
          RBIS is not a law firm and does not provide legal advice or representation. We are a behavioural and intelligence consultancy. All insights, reports, and tools provided by RBIS are designed to support legal professionals, organisations, and decision-makers. Reports are not legally binding and should not be treated as expert witness submissions unless explicitly commissioned under appropriate rules. Use of RBIS does not create a solicitor-client relationship.
        </p>
      </section>

      <section id="what" className="max-w-4xl mx-auto px-4">
        <h2 className="text-3xl font-semibold mb-4">What We Do</h2>
        <ul className="list-disc pl-5 space-y-2">
          <li>Assess behavioural patterns in communications and documentation</li>
          <li>Provide independent forensic-style reports to support professional proceedings</li>
          <li>Analyse digital and financial evidence to detect inconsistencies or anomalies</li>
          <li>Deliver live dashboards and predictive intelligence to support decision-making</li>
        </ul>
        <p className="mt-4 text-sm text-gray-600">Our services support, but do not replace, legal, regulatory, or professional advice.</p>
      </section>

      <section id="services" className="max-w-5xl mx-auto px-4">
        <h2 className="text-3xl font-semibold mb-8">Services</h2>
        <div className="space-y-6">
          <div className="bg-white shadow rounded p-6">
            <h3 className="text-2xl font-semibold">1. Evidence Handling & Verification</h3>
            <ul className="list-disc pl-5 mt-2 space-y-1">
              <li>Secure upload portals with encryption and GDPR-compliant protocols</li>
              <li>Evidence integrity validation (metadata, consistency, format)</li>
              <li>Support for WhatsApp, SMS, emails, audio, financial records, and more</li>
            </ul>
          </div>
          <div className="bg-white shadow rounded p-6">
            <h3 className="text-2xl font-semibold">2. Behavioural Intelligence Analysis</h3>
            <ul className="list-disc pl-5 mt-2 space-y-1">
              <li>Sentiment and tone pattern recognition</li>
              <li>Communication timeline mapping</li>
              <li>Behavioural anomaly detection using AI (flag-only; not automated decision-making)</li>
              <li>Human forensic review of AI insights</li>
            </ul>
          </div>
          <div className="bg-white shadow rounded p-6">
            <h3 className="text-2xl font-semibold">3. Independent Forensic-Style Reporting</h3>
            <ul className="list-disc pl-5 mt-2 space-y-1">
              <li>Reports formatted for legal, tribunal, HR, and organisational use</li>
              <li>Sections include: evidence summary, behavioural insights, AI flags, and human verification</li>
              <li>All findings are non-conclusive and provided as interpretative support</li>
            </ul>
          </div>
          <div className="bg-white shadow rounded p-6">
            <h3 className="text-2xl font-semibold">4. Housing Disrepair Claim Funnel (ClaimFix AI™)</h3>
            <ul className="list-disc pl-5 mt-2 space-y-1">
              <li>Public-facing intake system for tenants with disrepair complaints</li>
              <li>Fully compliant pre-screening questions (e.g., tenancy, arrears, landlord type)</li>
              <li>Referrals routed to solicitors under strict SRA marketing compliance protocols</li>
              <li>Disclaimers shown prior to submission; no outcome promises made</li>
            </ul>
          </div>
          <div className="bg-white shadow rounded p-6">
            <h3 className="text-2xl font-semibold">5. Intelligence Dashboards</h3>
            <ul className="list-disc pl-5 mt-2 space-y-1">
              <li>Visual insights for organisational decision-making</li>
              <li>Crisis room tools, executive trackers, risk mapping, and foresight modelling</li>
              <li>For use by qualified professionals; RBIS dashboards are not predictive guarantees</li>
            </ul>
          </div>
        </div>
      </section>

      <section id="compliance" className="max-w-4xl mx-auto px-4">
        <h2 className="text-3xl font-semibold mb-4">Compliance & Ethics</h2>
        <ul className="list-disc pl-5 space-y-2">
          <li><strong>UK GDPR & Data Ethics</strong>: Full DPA, data minimisation, retention controls</li>
          <li><strong>AI Use</strong>: AI is used as an assistive layer only; final decisions are human-driven</li>
          <li><strong>Confidentiality</strong>: All client data is handled under Mutual NDA terms</li>
          <li><strong>Transparency</strong>: All clients have access to retention policies and audit logs</li>
          <li><strong>Security</strong>: Encryption at rest and in transit; strict access protocols</li>
        </ul>
      </section>

      <section id="portal" className="max-w-4xl mx-auto px-4">
        <h2 className="text-3xl font-semibold mb-4">Client Portal Features</h2>
        <p className="mb-4">Accessible only after registration and consent.</p>
        <ul className="list-disc pl-5 space-y-1">
          <li>Secure Uploads</li>
          <li>Case Timeline (e.g., Intake → AI Review → Human Verification → Report Delivery)</li>
          <li>Report Download (Time-limited access)</li>
          <li>Message Centre</li>
          <li>Support Request Tool</li>
          <li>Right to delete data (DSAR-compliant)</li>
        </ul>
      </section>

      <section id="examples" className="max-w-5xl mx-auto px-4">
        <h2 className="text-3xl font-semibold mb-4">Use Case Examples</h2>
        <div className="grid md:grid-cols-3 gap-6">
          <div className="bg-white shadow rounded p-4">
            <h3 className="font-semibold">Housing Disputes</h3>
            <p className="text-sm mt-2">Support councils, solicitors, and housing bodies with evidence validation (e.g., tenant vs. landlord timelines).</p>
          </div>
          <div className="bg-white shadow rounded p-4">
            <h3 className="font-semibold">HR & Workplace Investigations</h3>
            <p className="text-sm mt-2">Behavioural communication audits and profile pattern analysis to assist HR teams.</p>
          </div>
          <div className="bg-white shadow rounded p-4">
            <h3 className="font-semibold">Financial Disputes</h3>
            <p className="text-sm mt-2">Support with bank record cross-checks, timeline irregularities, and digital activity.</p>
          </div>
        </div>
        <p className="mt-4 text-xs text-gray-600">All examples are anonymised or composite. Outcomes depend on external legal process and are not guaranteed.</p>
      </section>

      <section id="statement" className="max-w-4xl mx-auto px-4">
        <h2 className="text-3xl font-semibold mb-4">Final Statement</h2>
        <p>RBIS provides independent behavioural and forensic insights to support decision-makers in legal, regulatory, and organisational environments. We believe that clarity, credibility, and structured intelligence are essential in resolving disputes and making informed decisions. Our role is to assist — not to replace — the professionals who rely on evidence and analysis to act with confidence.</p>
      </section>

      <div className="text-center py-10">
        <Link href="#top" className="text-blue-600 hover:underline">Back to top</Link>
      </div>
    </div>
  );
}
