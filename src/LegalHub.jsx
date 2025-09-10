import React, { useMemo, useState, useEffect, useRef } from "react";

/**
 * RBIS Legal Hub — WATERTIGHT EDITION (single-file)
 * ---------------------------------------------------
 * What you get:
 *  - Full legal hub with cross-linked: Privacy Policy (UK GDPR), Terms of Service, Mutual NDA,
 *    Data Retention & Deletion Policy, Security Statement (Chain of Custody), Cookie Policy,
 *    Claims/Testimonial Accuracy Policy, and an optional Data Processing Addendum (DPA).
 *  - Helper UI: left nav, print/copy per section, anchors, scroll spy, contact block.
 *  - Helper components you can reuse across the site:
 *      • <RBISConsentSnippet /> — form consent with inline Privacy link and NDA option
 *      • <RBISCookieGate /> — simple consent-gating to hold analytics until granted
 *      • <RBISFooterLegal /> — footer links to /legal anchors
 *
 * How to use:
 *  1) Save as src/LegalHub.jsx and route to /legal.
 *  2) Add <RBISFooterLegal /> in your layout footer and <RBISCookieGate /> at app root.
 *  3) Replace ORG_* constants with your real details.
 *  4) If you act as a processor for clients, enable the DPA section.
 *
 * Tailwind is assumed for styling. Swap classes if you don't use it.
 */


// ======== ORG SETTINGS (edit these) ========
const ORG_LEGAL_NAME = "Ryan Roberts: Behavioural & Intelligence Services"; // trading/registered name
const ORG_SHORT = "RBIS";
const ORG_EMAIL = "contact@RBISIntelligence"; // provided by you
const ORG_ADDRESS = "PO Box, Bournemouth, Dorset, BH2 5RR, England"; // provided by you
const ORG_WEBSITE = "https://rbis.example"; // update to your real domain
const ORG_REGION = "England & Wales"; // Governing law & courts
const ORG_STORAGE_PROVIDER = "AWS S3 (encrypted at rest & in transit)"; // update if different
const ORG_PROCESSORS = [
  { name: "Formspree", purpose: "form submissions backend", policyUrl: "https://formspree.io/legal/privacy" },
  { name: "Google Tag Manager", purpose: "tag orchestration", policyUrl: "https://policies.google.com/privacy" },
  { name: "Google Analytics", purpose: "usage analytics", policyUrl: "https://policies.google.com/privacy" },
  { name: "Segment", purpose: "analytics routing", policyUrl: "https://segment.com/legal/privacy/" },
  { name: "Hotjar", purpose: "UX analytics (heatmaps/recordings)", policyUrl: "https://www.hotjar.com/legal/policies/privacy/" },
  { name: "Google Fonts", purpose: "font delivery (IP logs)", policyUrl: "https://policies.google.com/privacy" },
];


const POLICY_EFFECTIVE = "10 September 2025";
const POLICY_LAST_UPDATED = "10 September 2025";


// ======== helpers ========
function cx(...xs) { return xs.filter(Boolean).join(" "); }


function Section({ id, title, children, onCopy }) {
  const ref = useRef(null);
  return (
    <section id={id} ref={ref} className="scroll-mt-24">
      <div className="flex items-start justify-between gap-4">
        <h2 className="text-2xl font-semibold tracking-tight">{title}</h2>
        <div className="flex items-center gap-2">
          <a href={`#${id}`} className="text-sm underline opacity-70 hover:opacity-100" aria-label="Anchor">#</a>
          <button onClick={() => onCopy(ref)} className="text-sm rounded-lg border px-2 py-1 hover:bg-gray-50" aria-label="Copy">Copy</button>
          <button onClick={() => window.print()} className="text-sm rounded-lg border px-2 py-1 hover:bg-gray-50" aria-label="Print">Print</button>
        </div>
      </div>
      <div className="prose max-w-none mt-4">{children}</div>
      <hr className="my-10" />
    </section>
  );
}


export default function LegalHub() {
  const [active, setActive] = useState("privacy");
  const [copied, setCopied] = useState(null);


  const sections = useMemo(() => ([
    { id: "privacy", title: "Privacy Policy (UK GDPR)", Component: PrivacyPolicy },
    { id: "terms", title: "Terms of Service", Component: TermsOfService },
    { id: "nda", title: "Mutual Confidentiality Agreement (NDA)", Component: NDA },
    { id: "retention", title: "Data Retention & Deletion Policy", Component: RetentionPolicy },
    { id: "security", title: "Security Statement & Chain of Custody", Component: SecurityStatement },
    { id: "cookies", title: "Cookie Policy", Component: CookiePolicy },
    { id: "claims", title: "Claims, Testimonials & Marketing Accuracy", Component: ClaimsPolicy },
    { id: "dpa", title: "Data Processing Addendum (Controller ↔ Processor)", Component: DPA },
  ]), []);


  const onCopy = (ref) => {
    try {
      const range = document.createRange();
      range.selectNode(ref.current);
      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
      document.execCommand("copy");
      sel.removeAllRanges();
      setCopied("Section copied ✔");
      setTimeout(() => setCopied(null), 1800);
    } catch (e) {
      console.warn(e);
    }
  };

  // Scroll spy
  useEffect(() => {
    const obs = new IntersectionObserver((entries) => {
      entries.forEach((e) => { if (e.isIntersecting) setActive(e.target.id); });
    }, { rootMargin: "0px 0px -70% 0px", threshold: 0.1 });
    sections.forEach((s) => { const el = document.getElementById(s.id); if (el) obs.observe(el); });
    return () => obs.disconnect();
  }, [sections]);

  return (
    <div className="min-h-screen bg-white">
      <header className="sticky top-0 z-30 bg-white/80 backdrop-blur border-b">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <div>
            <h1 className="text-xl font-semibold">{ORG_SHORT} Legal Hub</h1>
            <p className="text-sm opacity-70">Effective: {POLICY_EFFECTIVE} • Last updated: {POLICY_LAST_UPDATED}</p>
          </div>
          <div className="flex gap-2">
            <a href="#privacy" className="text-sm rounded-lg border px-3 py-2 hover:bg-gray-50">Jump to Privacy</a>
            <button onClick={() => window.print()} className="text-sm rounded-lg border px-3 py-2 hover:bg-gray-50">Print All</button>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-8 grid grid-cols-1 md:grid-cols-12 gap-8">
        {/* Left nav */}
        <nav className="md:col-span-3 lg:col-span-3">
          <div className="sticky top-[90px]">
            <div className="rounded-2xl border p-3">
              <p className="text-xs uppercase text-gray-500 px-2">Documents</p>
              <ul className="mt-2">
                {sections.map((s) => (
                  <li key={s.id}>
                    <a href={`#${s.id}`} className={cx("block px-2 py-2 rounded-lg text-sm hover:bg-gray-50", active === s.id ? "bg-gray-100 font-medium" : "")}>{s.title}</a>
                  </li>
                ))}
              </ul>
              <div className="mt-4 text-xs text-gray-500 px-2 space-y-1">
                <p>Controller: <span className="font-medium">{ORG_LEGAL_NAME}</span></p>
                <p>Address: {ORG_ADDRESS}</p>
                <p>Contact: <a className="underline" href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a></p>
                <p>Website: <a className="underline" href={ORG_WEBSITE}>{ORG_WEBSITE}</a></p>
              </div>
              {copied && <div className="mt-3 text-xs text-green-700 bg-green-50 border border-green-200 rounded-lg p-2">{copied}</div>}
            </div>
          </div>
        </nav>

        {/* Content */}
        <div className="md:col-span-9 lg:col-span-9">
          {sections.map(({ id, title, Component }) => (
            <Section key={id} id={id} title={title} onCopy={onCopy}>
              <Component />
            </Section>
          ))}
        </div>
      </main>

      <footer className="border-t">
        <div className="max-w-6xl mx-auto px-4 py-6 text-sm text-gray-500">
          <p>These documents support compliance but do not replace tailored legal advice. We are not a law firm. Consult a solicitor for specific matters.</p>
          <div className="mt-2">
            <RBISFooterLegal />
          </div>
        </div>
      </footer>
    </div>
  );
}

// ================= REUSABLE SITE SNIPPETS =================
export function RBISFooterLegal() {
  return (
    <ul className="flex flex-wrap gap-4">
      <li><a className="underline" href="/legal#privacy">Privacy</a></li>
      <li><a className="underline" href="/legal#cookies">Cookies</a></li>
      <li><a className="underline" href="/legal#terms">Terms</a></li>
      <li><a className="underline" href="/legal#security">Security</a></li>
      <li><a className="underline" href="/legal#retention">Data Retention</a></li>
      <li><a className="underline" href="/legal#nda">NDA</a></li>
      <li><a className="underline" href="/legal#claims">Claims</a></li>
      <li><a className="underline" href="/legal#dpa">DPA</a></li>
    </ul>
  );
}

// Place at app root so tracking is OFF by default and only turns on post-consent.
export function RBISCookieGate() {
  const [consent, setConsent] = useState(() => {
    try { return JSON.parse(localStorage.getItem("rbis_cookie_consent") || "null"); } catch { return null; }
  });

  useEffect(() => {
    if (!consent) return; // still blocked

    // Example: enable Google Analytics via GTM after consent
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({ event: "rbis_consent_update", consent });

    // Example: enable Segment only if analytics permitted
    if (consent.analytics && window.analytics && typeof window.analytics.page === "function") {
      window.analytics.page();
    }

    // Example: enable Hotjar
    if (consent.analytics && window.hj) {
      window.hj("event", "consent_granted");
    }
  }, [consent]);

  const grant = (type) => {
    const next = { necessary: true, analytics: type !== "necessary", marketing: type === "all" };
    localStorage.setItem("rbis_cookie_consent", JSON.stringify(next));
    setConsent(next);
  };

  if (consent) return null; // consent already stored → nothing to show

  return (
    <div className="fixed bottom-4 inset-x-0 px-4 z-50">
      <div className="max-w-4xl mx-auto border rounded-2xl bg-white shadow p-4">
        <p className="text-sm">We use necessary cookies to run the site and optional analytics with your consent. Read our <a className="underline" href="/legal#cookies">Cookie Policy</a> and <a className="underline" href="/legal#privacy">Privacy Policy</a>.</p>
        <div className="mt-3 flex gap-2">
          <button className="border rounded-lg px-3 py-2 text-sm" onClick={() => grant("necessary")}>Decline non-essential</button>
          <button className="border rounded-lg px-3 py-2 text-sm" onClick={() => grant("analytics")}>Allow analytics</button>
          <button className="border rounded-lg px-3 py-2 text-sm" onClick={() => grant("all")}>Allow all</button>
        </div>
      </div>
    </div>
  );
}

// Inline consent snippet for forms (adds the “little link to Privacy Policy”) and NDA option.
export function RBISConsentSnippet({ requireNDA = false, onNDAToggle = () => {} }) {
  return (
    <div className="text-sm space-y-3">
      <label className="flex items-start gap-2">
        <input required type="checkbox" className="mt-1" />
        <span>I agree to confidential processing of my data per the <a className="underline" href="/legal#privacy" target="_blank" rel="noreferrer">Privacy Policy</a> and <a className="underline" href="/legal#terms" target="_blank" rel="noreferrer">Terms</a>.</span>
      </label>
      {requireNDA && (
        <label className="flex items-start gap-2">
          <input type="checkbox" className="mt-1" onChange={(e) => onNDAToggle(e.target.checked)} />
          <span>Request a <a className="underline" href="/legal#nda" target="_blank" rel="noreferrer">Mutual NDA</a> (we'll email you a DocuSign link).</span>
        </label>
      )}
      <p className="text-xs text-gray-500">Avoid uploading unnecessary special category data. If you do, you confirm you are providing it deliberately so we can assist you.</p>
    </div>
  );
}

// ================= DOCUMENTS =================
function PrivacyPolicy() {
  return (
    <div>
      <p><strong>Controller:</strong> {ORG_LEGAL_NAME} ("{ORG_SHORT}"). Contact: <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a>. Address: {ORG_ADDRESS}.</p>
      <p>This Privacy Policy explains how we process personal data under UK GDPR and the Data Protection Act 2018. It works with our <a href="#terms">Terms of Service</a>, <a href="#cookies">Cookie Policy</a>, <a href="#retention">Data Retention</a>, and <a href="#security">Security Statement</a>.</p>

      <h3>1) What we collect</h3>
      <ul>
        <li><strong>Identity & contact:</strong> name, email, phone, organisation, role.</li>
        <li><strong>Content you submit:</strong> descriptions, attachments/files (may include special category or criminal-offence data if you choose to upload).</li>
        <li><strong>Usage & telemetry:</strong> pages visited, time-to-complete (TTC), device/browser, IP address, referrer, session identifiers.</li>
        <li><strong>Comms:</strong> email, messages, support notes and metadata.</li>
        <li><strong>Marketing preferences:</strong> opt-ins and unsubscribe choices.</li>
        <li><strong>Children’s data:</strong> our services are not directed to children; do not submit children’s data.</li>
      </ul>

      <h3>2) Sources</h3>
      <p>Directly from you (forms/uploads/emails), automatically via cookies/SDKs, and from third parties where lawful (e.g., partners, public records).</p>

      <h3>3) Purposes & lawful bases</h3>
      <table>
        <thead>
          <tr><th>Purpose</th><th>Examples</th><th>Lawful basis</th></tr>
        </thead>
        <tbody>
          <tr><td>Provide & improve services</td><td>Intake, triage, generate documents, measure TTC, QA</td><td>Contract (Art.6(1)(b)); Legitimate interests (Art.6(1)(f))</td></tr>
          <tr><td>Comms</td><td>Service messages, updates, support</td><td>Contract; Legitimate interests</td></tr>
          <tr><td>Marketing</td><td>Newsletters/case studies (with consent)</td><td>Consent (PECR/Art.6(1)(a)); Legitimate interests for B2B where appropriate</td></tr>
          <tr><td>Security & fraud</td><td>MFA, RBAC, audit logs, incident response</td><td>Legitimate interests; Legal obligation</td></tr>
          <tr><td>Legal/regulatory</td><td>Handling complaints, enforcing terms, litigation</td><td>Legal obligation; Legitimate interests</td></tr>
        </tbody>
      </table>

      <h4>Special category data</h4>
      <p>If you submit sensitive data, we process it only where you have <strong>explicitly provided it</strong> and it is necessary to your request (UK GDPR Art. 9(2)(a)/(g)). Please avoid unnecessary sensitive uploads.</p>

      <h3>4) Sharing & processors</h3>
      <p>We use vetted providers under written terms acting on our instructions:</p>
      <ul>
        {ORG_PROCESSORS.map(p => (
          <li key={p.name}><strong>{p.name}</strong> — {p.purpose} (<a href={p.policyUrl} target="_blank" rel="noreferrer">policy</a>)</li>
        ))}
      </ul>
      <p>We may share data with professional advisers, courts, regulators, or law enforcement as required by law.</p>

      <h3>5) International transfers</h3>
      <p>Where data leaves the UK/EEA, we use adequacy decisions or appropriate safeguards (e.g., IDTA/SCCs).</p>

      <h3>6) Security</h3>
      <p>Encryption in transit (TLS), encryption at rest on {ORG_STORAGE_PROVIDER}, least-privilege access, MFA, and audit logging where supported. See <a href="#security">Security Statement</a>.</p>

      <h3>7) Retention</h3>
      <p>See <a href="#retention">Data Retention & Deletion Policy</a> for details; typical defaults are 24 months for enquiries/documents, 18 months for telemetry, and up to 6 years for statutory records.</p>

      <h3>8) Your rights</h3>
      <p>Access, rectification, erasure, restriction, portability, objection, and consent withdrawal. Contact <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a>. You can complain to the ICO: <a href="https://ico.org.uk" target="_blank" rel="noreferrer">ico.org.uk</a>.</p>

      <h3>9) Cookies & similar tech</h3>
      <p>See <a href="#cookies">Cookie Policy</a>. Non-essential tools run only after consent via <code>&lt;RBISCookieGate /&gt;</code>.</p>

      <h3>10) Contact & DPO</h3>
      <p>We are a small organisation and do not require a DPO. For privacy matters, email <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a> or write to {ORG_ADDRESS}.</p>

      <h3>11) Changes</h3>
      <p>We may update this policy and will post the new effective date here.</p>
    </div>
  );
}

function TermsOfService() {
  return (
    <div>
      <p>Welcome to {ORG_WEBSITE} operated by {ORG_LEGAL_NAME} ("{ORG_SHORT}", "we", "us"). By accessing or using our site or services, you agree to these Terms. See also our <a href="#privacy">Privacy Policy</a> and <a href="#cookies">Cookie Policy</a>.</p>

      <h3>1) Services & No Legal Advice</h3>
      <p>We provide information, automation, and document-generation tools. We are <strong>not a law firm</strong> and do not provide legal advice. Outputs should be reviewed by a qualified solicitor where appropriate. You remain responsible for your decisions.</p>

      <h3>2) Accounts & Acceptable Use</h3>
      <ul>
        <li>Provide accurate information and keep credentials secure.</li>
        <li>Do not upload unlawful content or third-party personal data without a lawful basis and authority.</li>
        <li>No reverse engineering, scraping, or security testing without our written consent.</li>
        <li>No misuse, spam, or interference with the service.</li>
      </ul>

      <h3>3) Fees, Refunds & Changes</h3>
      <p>Where fees apply, they are due in advance unless stated otherwise. Prices may change on notice. Refunds are at our discretion unless required by law.</p>

      <h3>4) Intellectual Property</h3>
      <p>The site, software, and content are owned by {ORG_SHORT} or our licensors. Subject to these Terms, we grant you a limited, non-exclusive, non-transferable licence to use the service. You retain ownership of your content; you grant us a licence to process it solely to provide and improve the services.</p>

      <h3>5) Confidentiality</h3>
      <p>We treat your non-public information as confidential and use it only to provide services, subject to disclosures to our vetted processors under written terms. For stricter terms or pre-contract exchanges, use our <a href="#nda">Mutual NDA</a>.</p>

      <h3>6) Data Protection</h3>
      <p>Our processing of personal data is described in the <a href="#privacy">Privacy Policy</a>. If we act as a processor for you, our <a href="#dpa">Data Processing Addendum</a> applies.</p>

      <h3>7) Warranties & Disclaimers</h3>
      <p>The services are provided on an <strong>“as is”</strong> and <strong>“as available”</strong> basis. We disclaim all implied warranties to the fullest extent permitted by law.</p>

      <h3>8) Limitation of Liability</h3>
      <p>Nothing excludes liability for death or personal injury due to negligence, fraud, or other liability that cannot be excluded by law. Subject to the foregoing, we are not liable for (a) indirect or consequential loss; (b) loss of profits, revenue, or data; and our aggregate liability is capped at the greater of £500 or the fees you paid in the 12 months before the claim.</p>

      <h3>9) Indemnity</h3>
      <p>You indemnify us for losses arising from your unlawful content, misuse, or breach of these Terms.</p>

      <h3>10) Suspension & Termination</h3>
      <p>We may suspend or terminate access for breach, risk, or legal obligation. You may stop using the services at any time.</p>

      <h3>11) Governing Law, Jurisdiction & Notices</h3>
      <p>These Terms are governed by the laws of {ORG_REGION}. The courts of {ORG_REGION} have exclusive jurisdiction (consumers may have mandatory local rights). Notices may be sent to <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a> or {ORG_ADDRESS}.</p>

      <h3>12) Changes; Entire Agreement</h3>
      <p>We may update these Terms; continued use after notice constitutes acceptance. These Terms form the entire agreement regarding the services.</p>
    </div>
  );
}

function NDA() {
  return (
    <div>
      <p><em>Operational tip:</em> Map the “NDA required” checkbox in your intake form to trigger an email/envelope via DocuSign/Adobe Sign using this text. Until executed, display: “NDA will be issued separately upon request.”</p>

      <h3>Mutual Confidentiality Agreement (Short Form)</h3>
      <p><strong>Parties:</strong> {ORG_LEGAL_NAME} ("{ORG_SHORT}") and the counterparty ("Recipient").</p>

      <h4>1) Definition</h4>
      <p>“Confidential Information” means non-public information disclosed by either party, including business plans, data, documents, code, models, prompts, training data, customer information, and any personal data, marked or reasonably understood as confidential.</p>

      <h4>2) Obligations</h4>
      <ul>
        <li>Use Confidential Information only to evaluate or perform the purpose discussed between the parties.</li>
        <li>Protect with reasonable care and restrict access to those with a need to know under confidentiality obligations.</li>
        <li>Do not disclose to third parties without prior written consent, except processors bound by written terms.</li>
      </ul>

      <h4>3) Exclusions</h4>
      <p>Information that is or becomes public without breach; already known without restriction; independently developed; or rightfully received from a third party without duty of confidentiality.</p>

      <h4>4) Compelled Disclosure</h4>
      <p>If legally required to disclose, notify promptly (unless unlawful) and disclose only what is necessary, seeking protective orders where possible.</p>

      <h4>5) Return/Deletion</h4>
      <p>On request or termination, promptly return or securely destroy Confidential Information, subject to routine backups and legal retention requirements.</p>

      <h4>6) No Licence</h4>
      <p>No rights are granted other than as expressly stated. All IP remains with the discloser.</p>

      <h4>7) Term</h4>
      <p>Obligations apply for <strong>5 years</strong> from disclosure; trade secrets survive as long as they remain trade secrets.</p>

      <h4>8) Remedies</h4>
      <p>Unauthorised use may cause irreparable harm; injunctive relief and other remedies are available in addition to damages.</p>

      <h4>9) Governing Law</h4>
      <p>{ORG_REGION} law; courts of {ORG_REGION}.</p>

      <h4>Execution</h4>
      <p>Signed electronically by the parties’ duly authorised representatives.</p>

      <p><strong>{ORG_LEGAL_NAME}</strong><br />{ORG_ADDRESS}<br />Contact: <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a></p>
    </div>
  );
}

function RetentionPolicy() {
  return (
    <div>
      <p>This policy describes how long we keep data and how we delete it. It must be read with our <a href="#privacy">Privacy Policy</a>.</p>

      <h3>Retention Schedule (default)</h3>
      <table>
        <thead><tr><th>Data category</th><th>Default retention</th><th>Notes</th></tr></thead>
        <tbody>
          <tr><td>Enquiries, cases, generated documents</td><td>24 months</td><td>Extended if there is an active matter, dispute, or legal hold</td></tr>
          <tr><td>Uploaded files (including sensitive)</td><td>24 months</td><td>Securely stored; early deletion on verified request where feasible</td></tr>
          <tr><td>Telemetry & analytics</td><td>18 months</td><td>Aggregated/anonymous metrics may be kept longer</td></tr>
          <tr><td>Contracts, invoices, corporate records</td><td>6 years</td><td>For tax, accounting, limitation periods</td></tr>
          <tr><td>Support tickets & emails</td><td>24 months</td><td>For continuity and traceability</td></tr>
          <tr><td>Backups</td><td>Rolling windows</td><td>Subject to fixed expiry; restores may temporarily surface deleted data</td></tr>
        </tbody>
      </table>

      <h3>Deletion Methods</h3>
      <ul>
        <li>Application-level delete for live stores; queued purge for derived indices and caches.</li>
        <li>Processor deletion via API or vendor tickets per SLA.</li>
        <li>Cryptographic erasure where supported on encrypted storage.</li>
      </ul>

      <h3>Requests</h3>
      <p>Submit deletion or access requests to <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a>. We verify identity and respond within statutory timeframes.</p>
    </div>
  );
}

function SecurityStatement() {
  return (
    <div>
      <p>We maintain proportionate security controls aligned with industry good practice for small organisations handling sensitive information.</p>

      <h3>Chain of Custody</h3>
      <ul>
        <li>Ingress via TLS-only endpoints; malware scanning for uploads.</li>
        <li>Storage on secure cloud ({ORG_STORAGE_PROVIDER}); encryption at rest; role-based access control (RBAC).</li>
        <li>Access restricted to authorised personnel (least-privilege) with MFA.</li>
        <li>Audit logs for administrative actions and data access where supported.</li>
      </ul>

      <h3>Operational Security</h3>
      <ul>
        <li>Vendor due diligence for processors; DPAs/IDTA/SCCs as required.</li>
        <li>Regular dependency updates and patching cadence.</li>
        <li>Secrets in secure vaults/environment stores; rotated periodically.</li>
        <li>Secure development practices; code review on critical paths.</li>
      </ul>

      <h3>Incident Response</h3>
      <ul>
        <li>Detect, contain, and remediate incidents promptly; document post-mortems.</li>
        <li>Notify affected users and regulators where legally required (ICO within 72 hours where feasible).</li>
      </ul>

      <h3>Business Continuity</h3>
      <ul>
        <li>Backups verified and restorable; monitored uptime; provider SLAs leveraged.</li>
      </ul>

      <h3>Contact</h3>
      <p>Report security concerns to <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a>.</p>
    </div>
  );
}

function CookiePolicy() {
  return (
    <div>
      <p>This Cookie Policy forms part of our <a href="#privacy">Privacy Policy</a> and <a href="#terms">Terms of Service</a>. Non-essential cookies run only with your consent.</p>

      <h3>Types of Cookies</h3>
      <ul>
        <li><strong>Strictly necessary:</strong> required for core functionality and security.</li>
        <li><strong>Analytics:</strong> to measure visits and performance (e.g., Google Analytics, Segment, Hotjar).</li>
        <li><strong>Functional:</strong> preferences such as saved inputs.</li>
        <li><strong>Marketing:</strong> only if explicitly enabled.</li>
      </ul>

      <h3>Consent</h3>
      <p>On first visit we request consent for non-essential cookies in accordance with PECR/UK GDPR. You can change or withdraw consent at any time via the cookie banner/settings.</p>

      <h3>Third-Party Technologies</h3>
      <ul>
        {ORG_PROCESSORS.map(p => (
          <li key={p.name}><strong>{p.name}</strong> — {p.purpose} (<a href={p.policyUrl} target="_blank" rel="noreferrer">policy</a>)</li>
        ))}
      </ul>

      <h3>Managing Cookies</h3>
      <p>You can block or delete cookies in your browser settings. Blocking some cookies may impact functionality.</p>
    </div>
  );
}

function ClaimsPolicy() {
  return (
    <div>
      <p>This policy governs how we make and substantiate claims in marketing, including testimonials, usage stats, and performance outcomes.</p>

      <h3>Substantiation</h3>
      <ul>
        <li>Claims like “legally defensible outputs” will include a footnote explaining scope, assumptions, and limitations.</li>
        <li>Statements such as “Used by councils and regulators” or numeric counts (e.g., “163 cases analysed”) must be supported by internal records and dated, e.g., “Based on internal data, last updated 10 Sep 2025”.</li>
      </ul>

      <h3>Testimonials</h3>
      <ul>
        <li>Testimonials reflect individual experiences; results vary. We disclose material connections (e.g., discounts).</li>
        <li>We obtain permission before publishing identifiable testimonials.</li>
      </ul>

      <h3>Accuracy & Updates</h3>
      <p>We review published claims periodically and correct errors or outdated statements promptly.</p>

      <h3>Contact</h3>
      <p>Questions: <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a></p>
    </div>
  );
}

function DPA() {
  return (
    <div>
      <p>This Data Processing Addendum (DPA) applies when {ORG_LEGAL_NAME} acts as a <strong>processor</strong> of personal data on behalf of a client (the <em>Controller</em>). When we are a <strong>controller</strong>, our <a href="#privacy">Privacy Policy</a> applies.</p>

      <h3>1) Processing Subject Matter & Duration</h3>
      <p>Processing personal data submitted to the services for the term of the underlying agreement.</p>

      <h3>2) Nature & Purpose</h3>
      <p>Hosting, storage, transmission, transformation and output generation per client instructions.</p>

      <h3>3) Types of Personal Data & Categories of Data Subjects</h3>
      <p>As provided by Controller at its discretion; may include contact data and documents related to cases or workflows.</p>

      <h3>4) Obligations of Processor</h3>
      <ul>
        <li>Process only on documented instructions from Controller, including regarding transfers.</li>
        <li>Confidentiality obligations for personnel; least-privilege access; MFA where applicable.</li>
        <li>Implement appropriate technical and organisational measures (see <a href="#security">Security Statement</a>).</li>
        <li>Assist Controller with data-subject requests and DPIAs where proportionate.</li>
        <li>Delete or return personal data at termination, subject to legal retention requirements (see <a href="#retention">Retention</a>).</li>
        <li>Make available information to demonstrate compliance and allow audits on reasonable notice.</li>
      </ul>

      <h3>5) Sub‑processors</h3>
      <p>We engage the providers listed in our <a href="#privacy">Privacy Policy</a> as sub‑processors under written terms. Controller authorises these and future equivalent providers provided we maintain materially similar or stronger protections.</p>

      <h3>6) International Transfers</h3>
      <p>Transfers outside the UK/EEA shall be subject to appropriate safeguards (IDTA/SCCs).</p>

      <h3>7) Incident Notification</h3>
      <p>We will notify Controller without undue delay after becoming aware of a personal data breach affecting Controller data, and provide information reasonably required for Controller to meet obligations.</p>

      <h3>8) Liability</h3>
      <p>Liability is as set out in the underlying agreement and our <a href="#terms">Terms</a>. Nothing limits liability where unlawful to do so.</p>

      <h3>9) Contact</h3>
      <p>Controller may contact us at <a href={`mailto:${ORG_EMAIL}`}>{ORG_EMAIL}</a> (subject “DPA”).</p>
    </div>
  );
}
