import Head from "next/head";
import Link from "next/link";

const s = {
  page: { fontFamily: "system-ui", color: "#111" } as React.CSSProperties,
  wrap: { padding: "2rem", lineHeight: 1.55, maxWidth: 1080, margin: "0 auto" } as React.CSSProperties,
  hero: { position: "relative", borderRadius: 16, padding: "28px 24px", overflow: "hidden" } as React.CSSProperties,
  heroTitle: { margin: 0, fontSize: 32, lineHeight: 1.15 } as React.CSSProperties,
  lead: { fontSize: 18, color: "#333", marginTop: 8, maxWidth: 900 } as React.CSSProperties,
  section: { marginTop: 32 } as React.CSSProperties,
  h2: { margin: "0 0 8px", fontSize: 24 } as React.CSSProperties,
  muted: { color: "#666" } as React.CSSProperties,
  grid: { display: "grid", gap: 16, gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))", marginTop: 16 } as React.CSSProperties,
  card: { position: "relative", border: "1px solid #e9e9e9", borderRadius: 14, padding: 20, background: "#fff" } as React.CSSProperties,
  tag: { fontSize: 12, background: "#f4f4f5", padding: "2px 8px", borderRadius: 999, display: "inline-block", marginBottom: 8 } as React.CSSProperties,
  priceRow: { display: "flex", gap: 8, alignItems: "baseline", flexWrap: "wrap", marginTop: 8 } as React.CSSProperties,
  priceBig: { fontWeight: 800, fontSize: 22 } as React.CSSProperties,
  priceSmall: { color: "#444" } as React.CSSProperties,
  list: { margin: "8px 0 0 18px" } as React.CSSProperties,
  hr: { borderTop: "1px solid #eee", margin: "24px 0" } as React.CSSProperties,
  btnRow: { display: "flex", gap: 12, flexWrap: "wrap", marginTop: 12 } as React.CSSProperties,
  btn: { padding: "10px 14px", borderRadius: 10, border: "1px solid #111", textDecoration: "none" } as React.CSSProperties,
  ribbon: {
    position: "absolute", top: 10, right: -8, background: "#111", color: "#fff",
    padding: "4px 12px", borderRadius: "999px", fontSize: 12
  } as React.CSSProperties,
  iconRow: { display: "flex", gap: 10, alignItems: "center", marginBottom: 6 } as React.CSSProperties,
  iconWrap: { width: 20, height: 20 } as React.CSSProperties,
};

function IconCheck() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" aria-hidden="true">
      <path d="M8 13.2 4.8 10l-1.1 1.1L8 15.5l8.3-8.3L15.2 6z" />
    </svg>
  );
}
function IconSpark() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" aria-hidden="true">
      <path d="M9.5 1 8 7 2 8.5 8 10l1.5 6 1.5-6 6-1.5-6-1.5z" />
    </svg>
  );
}
function IconLedger() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" aria-hidden="true">
      <path d="M4 3h10a2 2 0 0 1 2 2v10H6a2 2 0 0 1-2-2V3zM6 7h8M6 10h8M6 13h6" />
    </svg>
  );
}

export default function Solutions() {
  return (
    <>
      <Head>
        <title>Solutions — RBIS Intelligence</title>
        <meta
          name="description"
          content="Veridex smart funnel, PACT Ledger promise OS, and evidence-ready reports. Simple pricing with £250/mo support across the suite."
        />
      </Head>

      <div style={s.page}>
        <main style={s.wrap}>
          {/* HERO */}
          <section style={s.hero} className="rbis-hero">
            <h1 style={s.heroTitle}>Solutions</h1>
            <p style={s.lead}>
              Smart compliance. Structured evidence. Audit-ready from first click.
              RBIS delivers three pillars: <b>Veridex</b> (the smart funnel), <b>PACT Ledger</b> (promise enforcement),
              and <b>Evidence Reports</b>. Pricing is simple and competitive: <b>all products require £250/mo IT &amp; Web Support</b>
              so your system stays patched, compliant, and monitored.
            </p>
          </section>

          {/* VERIDEX */}
          <section style={s.section} id="veridex">
            <h2 style={s.h2}>Veridex — The Smart Funnel</h2>
            <p style={s.muted}>One funnel for any journey: repairs, complaints, claims, compliance, audits.</p>

            <div style={s.grid}>
              <div style={s.card} className="rbis-card">
                <span style={s.tag}>Lite</span>
                <div style={s.iconRow}><span style={s.iconWrap}><IconSpark/></span><h3 style={{margin:0}}>Entry Funnel</h3></div>
                <p>Adaptive branching with structured exports. Irrelevant questions never appear.</p>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>£490</span><span style={s.priceSmall}>setup</span>
                  <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo support</span>
                </div>
              </div>

              <div style={{...s.card, border: "2px solid #111"}} className="rbis-card">
                <div style={s.ribbon} aria-label="Recommended">Recommended</div>
                <span style={s.tag}>Pro</span>
                <div style={s.iconRow}><span style={s.iconWrap}><IconCheck/></span><h3 style={{margin:0}}>Behavioural Funnel</h3></div>
                <p>Behavioural microcopy, quality checks for media, evidence-ready packs with timestamps & consent trail.</p>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>£1,450</span><span style={s.priceSmall}>setup</span>
                  <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo support</span>
                </div>
              </div>

              <div style={s.card} className="rbis-card">
                <span style={s.tag}>Enterprise</span>
                <div style={s.iconRow}><span style={s.iconWrap}><IconSpark/></span><h3 style={{margin:0}}>Universal Funnel</h3></div>
                <p>Multi-workflow use (repairs, complaints, compliance forms, audits) with reporting overlays.</p>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>£4,900</span><span style={s.priceSmall}>setup</span>
                  <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo support</span>
                </div>
              </div>
            </div>

            <div style={s.btnRow}>
              <Link href="/veridex" style={s.btn}>Explore Veridex</Link>
              <Link href="/hdr" style={s.btn}>See HDR example</Link>
            </div>
          </section>

          <div style={s.hr} />

          {/* PACT LEDGER */}
          <section style={s.section} id="pact">
            <h2 style={s.h2}>PACT Ledger — Promise OS</h2>
            <p style={s.muted}>Makes commitments trackable, enforceable, and evidence-backed.</p>

            <div style={s.card} className="rbis-card">
              <div style={s.iconRow}><span style={s.iconWrap}><IconLedger/></span><h3 style={{margin:0}}>Ledger Add-On</h3></div>
              <p>Turn promises (repairs, payments, deliveries) into time-stamped evidence with nudges and escalation.</p>
              <div style={s.priceRow}>
                <span style={s.priceBig}>£750</span><span style={s.priceSmall}>setup</span>
                <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo support</span>
              </div>
            </div>
          </section>

          <div style={s.hr} />

          {/* REPORTS */}
          <section style={s.section} id="reports">
            <h2 style={s.h2}>RBIS Reports & Audits</h2>
            <p style={s.muted}>Legally-safe, evidence-based templates ready for regulators.</p>
            <p><b>Single report:</b> £290 each &nbsp; • &nbsp; <b>Full bundle (31 templates):</b> £4,900 setup + £250/mo support</p>

            <div style={s.grid}>
              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>Housing Repairs & Compliance</h3>
                <ul style={s.list}>
                  <li>Repairs Intake Summary</li>
                  <li>Damp &amp; Mould Assessment</li>
                  <li>Leak / Water Ingress Incident</li>
                  <li>Heating / Hot Water Failure</li>
                  <li>Electrical Safety Incident</li>
                  <li>Structural Defect Report</li>
                  <li>Pest / Infestation Report</li>
                  <li>Gas Safety Concern</li>
                  <li>Asbestos Suspected Material</li>
                  <li>Fire Safety / Alarm Fault</li>
                </ul>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>Complaints & Ombudsman</h3>
                <ul style={s.list}>
                  <li>Stage 1 Complaint Summary</li>
                  <li>Stage 2 Escalation Dossier</li>
                  <li>Ombudsman Referral Pack</li>
                  <li>Maladministration Risk Review</li>
                  <li>Service Failure Root Cause</li>
                </ul>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>Data Protection & Marketing</h3>
                <ul style={s.list}>
                  <li>GDPR Art.30 ROPA Extract</li>
                  <li>DPIA (Template & Log)</li>
                  <li>DSAR Fulfilment Log</li>
                  <li>Breach Notification Summary</li>
                  <li>PECR Marketing Consent Audit</li>
                  <li>Cookie Compliance Audit</li>
                  <li>ASA Advertising Substantiation Pack</li>
                </ul>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>Website & Accessibility</h3>
                <ul style={s.list}>
                  <li>WCAG 2.1 AA Audit</li>
                  <li>Accessibility Statement</li>
                  <li>Content Readability Report</li>
                  <li>Tracking & Tag Governance</li>
                </ul>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>Operational Performance & Auditability</h3>
                <ul style={s.list}>
                  <li>SLA Compliance Report</li>
                  <li>Backlog &amp; Aged Cases</li>
                  <li>First-Contact Resolution Analysis</li>
                </ul>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>PACT Ledger Reports</h3>
                <ul style={s.list}>
                  <li>Promise Register Export</li>
                  <li>Escalation Trail &amp; Outcome</li>
                </ul>
              </div>
            </div>

            <div style={s.btnRow}>
              <Link href="/contact?intent=consult" style={s.btn}>Request sample reports</Link>
            </div>
          </section>

          <div style={s.hr} />

          {/* WEBSITES & AI */}
          <section style={s.section} id="sites">
            <h2 style={s.h2}>Custom Sites & AI Packages</h2>
            <p style={s.muted}>From bakery-simple to enterprise-grade — always with compliance built-in.</p>

            <div style={s.grid}>
              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>Starter Website</h3>
                <p>1–3 pages, basic SEO, privacy & cookies included.</p>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>£290</span><span style={s.priceSmall}>setup</span>
                  <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo support</span>
                </div>
              </div>

              <div style={{...s.card, border: "2px solid #111"}} className="rbis-card">
                <div style={s.ribbon}>Recommended</div>
                <h3 style={{marginTop:0}}>Professional Website</h3>
                <p>5–10 pages, blog, Trust Centre, performance & accessibility pass.</p>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>£1,450</span><span style={s.priceSmall}>setup</span>
                  <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo support</span>
                </div>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>Enterprise Website</h3>
                <p>Multi-product, gated content, dashboards, SLA timers.</p>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>£4,900</span><span style={s.priceSmall}>setup</span>
                  <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo support</span>
                </div>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>OmniAssist Automation</h3>
                <p>Copilot for repetitive tasks: enrich, triage, summarize, draft replies.</p>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>£750</span><span style={s.priceSmall}>setup</span>
                  <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo monitoring & support</span>
                </div>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>RBIS Dashboard</h3>
                <p>Exec insights: intake health, SLA risk, consent split, Lighthouse scores.</p>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>£750</span><span style={s.priceSmall}>setup</span>
                  <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo</span>
                </div>
              </div>

              <div style={s.card} className="rbis-card">
                <h3 style={{marginTop:0}}>NextusOne CRM (Licences)</h3>
                <p>AI-native CRM with compliance overlays (consent, retention, audit trail).</p>
                <ul style={s.list}>
                  <li>Lite — £15 / user / mo</li>
                  <li>Pro — £39 / user / mo</li>
                  <li>Enterprise — £79 / user / mo</li>
                </ul>
                <div style={s.priceRow}>
                  <span style={s.priceBig}>+ £250</span><span style={s.priceSmall}>/mo support</span>
                </div>
              </div>
            </div>
          </section>

          <div style={s.hr} />

          {/* TOOLKIT */}
          <section style={s.section} id="toolkit">
            <h2 style={s.h2}>RBIS Toolkit Suite & Site Licence</h2>
            <p style={s.muted}>Copy-licence our compliant website & toolkit — fast go-live with safety guaranteed.</p>
            <ul style={s.list}>
              <li>Behavioural, adaptive enquiry form (Veridex-ready)</li>
              <li>Privacy by design: GDPR/DPA &amp; PECR consent split</li>
              <li>WCAG 2.1 AA patterns, labelled fields, keyboard flow</li>
              <li>Trust Centre scaffolding (policies, subprocessors, status JSON)</li>
              <li>Security headers &amp; CSP, referrer policy</li>
              <li>Retention hooks + deletion workflows (log-ready)</li>
              <li>Audit trail scaffolding (timestamps, consent, handling trail)</li>
              <li>Evidence pack structure (export-ready)</li>
            </ul>
            <div style={s.priceRow}>
              <span style={s.priceBig}>£290</span><span style={s.priceSmall}>/year licence</span>
              <span style={s.priceBig}>£250</span><span style={s.priceSmall}>/mo support</span>
            </div>
            <div style={s.btnRow}>
              <Link href="/contact?intent=enquiry" style={s.btn}>Get the Toolkit</Link>
            </div>
          </section>
        </main>
      </div>

      {/* Minimal, dependency-free visuals */}
      <style>{`
        .rbis-hero::before {
          content: "";
          position: absolute;
          inset: -30%;
          background: radial-gradient(60% 60% at 20% 20%, #efefef 0%, transparent 60%),
                      radial-gradient(50% 50% at 80% 30%, #f6f6f6 0%, transparent 60%),
                      radial-gradient(70% 70% at 60% 80%, #f1f1f1 0%, transparent 70%);
          animation: rbisGlow 8s ease-in-out infinite alternate;
        }
        @keyframes rbisGlow {
          0%   { transform: translate3d(-2%, -1%, 0) scale(1); opacity: .85; }
          100% { transform: translate3d(1%, 2%, 0) scale(1.03); opacity: 1; }
        }
        .rbis-card { transition: transform .15s ease, box-shadow .15s ease; }
        .rbis-card:hover, .rbis-card:focus-within {
          transform: translateY(-2px);
          box-shadow: 0 6px 18px rgba(0,0,0,.06);
        }
        /* SVGs inherit currentColor for consistency */
        svg { stroke: currentColor; fill: none; stroke-width: 1.6; }
        @media (prefers-reduced-motion: reduce) {
          .rbis-hero::before { animation: none; }
          .rbis-card { transition: none; }
        }
      `}</style>
    </>
  );
}
