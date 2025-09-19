import Head from "next/head";
import Link from "next/link";

const s = {
  wrap: { fontFamily: "system-ui", color: "#111", padding: "24px" } as React.CSSProperties,
  hero: { maxWidth: 980, margin: "0 auto 24px" } as React.CSSProperties,
  h1: { fontSize: 36, lineHeight: 1.1, margin: "0 0 8px" } as React.CSSProperties,
  lead: { fontSize: 18, color: "#444", margin: "0 0 16px" } as React.CSSProperties,
  ctas: { display: "flex", gap: 12, flexWrap: "wrap", marginBottom: 16 } as React.CSSProperties,
  btnPri: { padding: "12px 16px", background: "#111", color: "#fff", borderRadius: 8, textDecoration: "none" } as React.CSSProperties,
  btnSec: { padding: "12px 16px", border: "1px solid #111", borderRadius: 8, textDecoration: "none" } as React.CSSProperties,
  grid: { maxWidth: 980, margin: "24px auto 0", display: "grid", gap: 16, gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))" } as React.CSSProperties,
  card: { border: "1px solid #eee", borderRadius: 12, padding: 20 } as React.CSSProperties,
  step: { display: "grid", gap: 12, maxWidth: 980, margin: "32px auto 0" } as React.CSSProperties,
  faq: { maxWidth: 980, margin: "32px auto", borderTop: "1px solid #eee", paddingTop: 16 } as React.CSSProperties
};

export default function HDR() {
  return (
    <>
      <Head>
        <title>HDR — Report disrepair in minutes | RBIS</title>
        <meta name="description" content="Structured HDR intake with behavioural UX. Guided media capture, timeline builder, and auto evidence pack — audit-ready from first click." />
      </Head>

      <main style={s.wrap}>
        <section style={s.hero}>
          <h1 style={s.h1}>Report disrepair in minutes</h1>
          <p style={s.lead}>Structured intake. Evidence-ready outputs. Clear next steps.</p>
          <div style={s.ctas}>
            <Link href="/hdr/intake" style={s.btnPri}>Start HDR Intake</Link>
            <Link href="/solutions#hdr" style={s.btnSec}>Learn more</Link>
          </div>

          <div style={s.grid}>
            {[
              { t: "Photo & video capture", d: "Inline guidance and quality checks reduce unusable media." },
              { t: "Timeline builder", d: "Dates, issues, and remediation history in one coherent thread." },
              { t: "Auto evidence pack", d: "Generate a clean, reviewable dossier for legal teams or landlords." },
              { t: "Secure sharing", d: "One-time links for case teams and regulators." }
            ].map((x, i) => (
              <div key={i} style={s.card}>
                <h3 style={{ margin: "0 0 8px" }}>{x.t}</h3>
                <p style={{ margin: 0, color: "#444" }}>{x.d}</p>
              </div>
            ))}
          </div>

          <div style={s.step}>
            <h2>How it works</h2>
            <ol style={{ paddingLeft: 18, margin: 0, color: "#444" }}>
              <li><b>Quick questions</b> — address, issue types, urgency, vulnerabilities.</li>
              <li><b>Guided evidence</b> — photos/videos with prompts to avoid missing context.</li>
              <li><b>Timeline</b> — when it started, communications, attempted fixes.</li>
              <li><b>Review & submit</b> — you get a receipt; the team gets a structured case.</li>
              <li><b>Evidence pack</b> — on request, we generate a dossier (timestamps, consent text, IP, handling trail).</li>
            </ol>
          </div>

          <div style={s.faq}>
            <h2>FAQ</h2>
            <details>
              <summary>Is this legally compliant?</summary>
              <p>Yes. GDPR/DPA, PECR, and WCAG 2.1 AA are built-in. See our <Link href="/trust-centre">Trust Centre</Link>.</p>
            </details>
            <details>
              <summary>Where does my data go?</summary>
              <p>Encrypted systems with least-privilege access. We keep audit logs separate from personal data.</p>
            </details>
            <details>
              <summary>Can I edit my submission?</summary>
              <p>You can reply to your receipt email with updates. For corrections or deletion, email <a href="mailto:Contact@RBISIntelligence.com">Contact@RBISIntelligence.com</a>.</p>
            </details>
          </div>

          <div style={s.ctas}>
<Link href="/hdr/intake" style={s.btnPri}>Start HDR Intake</Link>
<Link href="/hdr/intake" style={s.btnPri}>Start HDR Intake</Link>
          </div>
        </section>
      </main>
    </>
  );
}
