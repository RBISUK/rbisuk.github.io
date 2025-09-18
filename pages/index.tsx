import Head from "next/head";
import Link from "next/link";

const Header = () => (
  <header style={{padding:"16px 24px", borderBottom:"1px solid #eee", display:"flex", gap:24, alignItems:"center", justifyContent:"space-between", fontFamily:"system-ui"}}>
    <div style={{fontWeight:700}}>RBIS Intelligence</div>
    <nav style={{display:"flex", gap:16}}>
      <Link href="/solutions">Solutions</Link>
      <Link href="/veridex">Veridex</Link>
      <Link href="/pact-ledger">PACT Ledger</Link>
      <Link href="/contact">Contact</Link>
      <Link href="/privacy">Privacy</Link>
    </nav>
  </header>
);

const Footer = () => (
  <footer style={{fontFamily:"system-ui", padding:"24px", borderTop:"1px solid #eee", marginTop:56}}>
    <div style={{display:"flex", gap:16, flexWrap:"wrap"}}>
      <Link href="/privacy">Privacy</Link>
      <a href="/health.txt" style={{opacity:0.6}}>Health</a>
    </div>
    <div style={{marginTop:8, color:"#666"}}>© {new Date().getFullYear()} RBIS Intelligence</div>
  </footer>
);

export default function Home() {
  return (
    <>
      <Head>
        <title>RBIS Intelligence — Compliance at First Contact</title>
        <meta name="description" content="Behavioural, adaptive, compliant-by-design systems. Veridex handles intake; PACT Ledger governs commitments." />
      </Head>
      <Header/>
      <main style={{fontFamily:"system-ui", padding:"56px 24px"}}>
        <section style={{maxWidth:920, margin:"0 auto"}}>
          <h1 style={{fontSize:40, lineHeight:1.1, margin:"0 0 12px"}}>Compliance at First Contact — powered by behavioural intelligence</h1>
          <p style={{fontSize:18, color:"#444", margin:"0 0 24px"}}>
            Veridex turns intake into assurance. PACT Ledger makes promises clear, kept, and enforceable. Built for regulated organisations that need user ease and legal safety at the same time.
          </p>
          <div style={{display:"flex", gap:12, flexWrap:"wrap"}}>
            <Link href="/contact" style={{padding:"12px 16px", background:"#111", color:"#fff", borderRadius:8, textDecoration:"none"}}>Start a smart enquiry</Link>
            <Link href="/veridex" style={{padding:"12px 16px", border:"1px solid #111", borderRadius:8, textDecoration:"none"}}>Explore Veridex</Link>
            <Link href="/pact-ledger" style={{padding:"12px 16px", border:"1px solid #111", borderRadius:8, textDecoration:"none"}}>Explore PACT Ledger</Link>
          </div>
        </section>

        <section style={{maxWidth:980, margin:"56px auto 0", display:"grid", gap:16, gridTemplateColumns:"repeat(auto-fit, minmax(260px, 1fr))"}}>
          {[
            {title:"Adaptive by design", body:"Flows change based on answers — fewer drop-offs, better data."},
            {title:"Compliance built in", body:"GDPR/DPA, PECR, WCAG 2.1 AA, and audit logs from the first click."},
            {title:"Defensible records", body:"Export packs with timestamps, consent wording, IP, and handling trail."},
            {title:"Continuous monitoring", body:"SLA timers, drift alerts, and RBIS Certified quarterly evidence."}
          ].map((c,i)=>(
            <div key={i} style={{border:"1px solid #eee", borderRadius:12, padding:20}}>
              <h3 style={{margin:"0 0 8px"}}>{c.title}</h3>
              <p style={{margin:0, color:"#444"}}>{c.body}</p>
            </div>
          ))}
        </section>
      </main>
      <Footer/>
    </>
  );
}
