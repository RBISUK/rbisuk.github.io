export default function Page() {
  return (
    <section className="hero">
      <h1 style={{fontSize:32, fontWeight:600, margin:0}}>Report disrepair in minutes</h1>
      <p style={{marginTop:12, color:'#555'}}>Structured intake. Evidence-ready outputs. Clear next steps.</p>
      <div style={{marginTop:16, display:'flex', gap:12}}>
        <a className="btn" href="#">Start HDR Intake</a>
        <a className="link" href="https://rbisintelligence.com">Learn more</a>
      </div>

      <div style={{marginTop:32}} className="grid">
        <div className="card"><strong>Photo & video capture</strong><p>Inline guidance and quality checks.</p></div>
        <div className="card"><strong>Timeline builder</strong><p>Dates, events, and remediation history.</p></div>
        <div className="card"><strong>Auto evidence pack</strong><p>Generate a clean, reviewable dossier.</p></div>
        <div className="card"><strong>Secure links</strong><p>Share with case teams and regulators.</p></div>
      </div>
    </section>
  );
}
