export default function Home() {
  return (
    <section className="hero">
      <div className="grid" style={{alignItems:'center'}}>
        <div>
          <h1>Evidence-led repairs & compliance — <span style={{color:'#0c2f79'}}>RBIS Intelligence</span></h1>
          <p className="lead">Collect, structure, and act on housing disrepair data. Be audit-ready by design.</p>
          <div style={{marginTop:16, display:'flex', gap:12}}>
            <a className="btn" href="https://hdr.rbisintelligence.com">Start HDR Intake</a>
            <a href="#contact" style={{textDecoration:'underline', color:'#2f75ff'}}>Talk to Sales</a>
          </div>
        </div>
        <div className="card">
          <ul style={{margin:0, paddingLeft:18}}>
            <li>Automated evidence packs</li>
            <li>Timeline builder</li>
            <li>Risk dashboards</li>
            <li>Secure document vault</li>
          </ul>
        </div>
      </div>

      <div id="products" className="section">
        <h2>Products</h2>
        <div className="grid">
          <div className="card"><strong>RBIS Core</strong><p>Centralise case data and evidence.</p></div>
          <div className="card"><strong>HDR Intake</strong><p>Resident-led intake with structured outputs.</p></div>
          <div className="card"><strong>Compliance</strong><p>Audit trails and statutory reporting.</p></div>
        </div>
      </div>

      <div id="pricing" className="section">
        <h2>Pricing</h2>
        <div className="card"><p>Founding partners pricing on request. Per-organisation licensing with fair usage.</p></div>
      </div>

      <div id="contact" className="section">
        <h2>Contact</h2>
        <p>Email: hello@rbisintelligence.com</p>
      </div>
    </section>
  );
}
