import { useEffect, useState } from "react";

type Sub = { name:string; purpose:string; dataCategories:string[]; region:string; dpa?:string };

export default function TrustCentre(){
  const [subs, setSubs] = useState<Sub[]>([]);
  const [status, setStatus] = useState<any>(null);

  useEffect(() => {
    fetch("/trust/subprocessors/list.json").then(r=>r.json()).then(setSubs).catch(()=>{});
    fetch("/trust/status/current.json").then(r=>r.json()).then(setStatus).catch(()=>{});
  }, []);

  const th:any = { textAlign:"left", borderBottom:"1px solid #ddd", padding:"8px" };
  const td:any = { borderBottom:"1px solid #f0f0f0", padding:"8px", verticalAlign:"top" };

  return (
    <main style={{fontFamily:"system-ui", padding:"2rem", lineHeight:1.55, maxWidth:980, margin:"0 auto"}}>
      <h1>RBIS Trust Centre</h1>
      <p>The Legal Hub for RBIS: policies, evidence, certifications, live status, and subprocessors — public by default.</p>

      <section style={{marginTop:24}}>
        <h2>Quick Links</h2>
        <ul>
          <li><a href="/trust/policies/privacy.html">Privacy Policy</a></li>
          <li><a href="/trust/policies/cookies.html">Cookie Policy</a></li>
          <li><a href="/trust/policies/retention.html">Data Retention</a></li>
          <li><a href="/trust/accessibility/statement.html">Accessibility Statement</a></li>
          <li><a href="/trust/security/overview.html">Security Overview</a></li>
          <li><a href="/trust/evidence/2025-Q4/Compliance_Evidence_Pack.txt">Compliance Evidence Pack (Q4 2025)</a></li>
          <li><a href="/trust/evidence/2025-Q4/RBIS_Certified_Certificate.txt">RBIS Certified Certificate (Q4 2025)</a></li>
        </ul>
      </section>

      <section style={{marginTop:24}}>
        <h2>Live Status</h2>
        <div style={{border:"1px solid #eee", borderRadius:12, padding:16}}>
          {!status ? <p>Loading status…</p> : (
            <>
              <p><b>Overall:</b> {status.overall} <span style={{opacity:0.6}}>(updated {new Date(status.lastUpdated).toLocaleString()})</span></p>
              <ul>{status.services.map((s:any, i:number)=>(<li key={i}><b>{s.name}</b>: {s.status}</li>))}</ul>
            </>
          )}
        </div>
      </section>

      <section style={{marginTop:24}}>
        <h2>Subprocessors</h2>
        <div style={{overflowX:"auto"}}>
          <table style={{borderCollapse:"collapse", width:"100%"}}>
            <thead><tr><th style={th}>Name</th><th style={th}>Purpose</th><th style={th}>Data</th><th style={th}>Region</th><th style={th}>DPA</th></tr></thead>
            <tbody>
              {subs.map((s, i)=>(
                <tr key={i}>
                  <td style={td}>{s.name}</td>
                  <td style={td}>{s.purpose}</td>
                  <td style={td}>{s.dataCategories.join(", ")}</td>
                  <td style={td}>{s.region}</td>
                  <td style={td}>{s.dpa ? <a href={s.dpa} target="_blank">Link</a> : "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </main>
  );
}
