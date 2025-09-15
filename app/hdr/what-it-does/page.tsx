export const metadata = {
  title: "What Claim-Fix-AI does (plain English)",
  description: "Everything a handler needs from click to case; 12 interlocking elements mapped.",
};
export default function Page() {
  return (
    <article className="prose max-w-none">
      <h1>What it does — in plain English</h1>
      <ul>
        <li>Captures tenancy details, chronology, media, vulnerability flags, expenses.</li>
        <li>Auto-triage with severity scoring, de-dupe, and missing-evidence prompts.</li>
        <li>Builds an evidence pack (PDF/ZIP + JSON) ready for CRM/DMS.</li>
        <li>Starts SLAs with letters, nudges, escalations, and audit-ready timelines.</li>
      </ul>

      <h2>One form, many claim types</h2>
      <p>Smart branching for Damp & Mould • Leaks/Plumbing • Heating/Boiler • Electrical Hazards • Structural Issues • Infestation • Injury.</p>
      <ul>
        <li><strong>Mould-related illness:</strong> request NHS proof, GP dates, medication; Art. 9(2)(f) basis applied.</li>
        <li><strong>Boiler failure:</strong> capture outage duration, coldest temp, vulnerable persons, emergency costs.</li>
        <li>Room-by-room capture with severity sliders + guided photo prompts.</li>
      </ul>

      <h2>12 elements from click to case</h2>
      <ol>
        <li>Frontend Intake (React/Framer, CDN)</li><li>Consent Ledger (PECR-compliant)</li><li>Direct Media Uploader</li>
        <li>Case DB</li><li>Session/De-dupe Cache</li><li>AI Triage Engine</li><li>SLA Timers</li>
        <li>Notifier (SMS/WhatsApp/email)</li><li>Evidence-Pack Builder</li><li>Audit Logger</li>
        <li>CRM/DMS Webhook</li><li>Dashboards</li>
      </ol>
    </article>
  );
}
