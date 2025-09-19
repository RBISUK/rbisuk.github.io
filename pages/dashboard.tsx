// pages/dashboard.tsx
import * as React from "react";
import { REPORTS, type ReportItem } from "../data/reports";

export default function Dashboard() {
  const [q, setQ] = React.useState("");
  const [cat, setCat] = React.useState<string>("All");

  const categories = React.useMemo(
    () => ["All", ...Array.from(new Set(REPORTS.map(r => r.category)))],
    []
  );

  const filtered = REPORTS.filter(r => {
    const inCat = cat === "All" || r.category === (cat as ReportItem["category"]);
    const text = (r.title + " " + r.org + " " + (r.summary ?? "")).toLowerCase();
    return inCat && text.includes(q.toLowerCase());
  });

  return (
    <main style={{maxWidth: 1100, margin: "40px auto", padding: "0 16px"}}>
      <header style={{display:"flex",justifyContent:"space-between",alignItems:"end",gap:16,flexWrap:"wrap"}}>
        <div>
          <h1 style={{margin:"0 0 6px"}}>RBIS Reports</h1>
          <p style={{opacity:.8,margin:0}}>
            Curated demos covering repairs & compliance, complaints timeliness, escalations, Ombudsman readiness, and root-cause analysis.
          </p>
        </div>
        <div style={{display:"flex",gap:8, alignItems:"center", flexWrap:"wrap"}}>
          <input
            placeholder="Search reports…"
            value={q}
            onChange={e => setQ(e.target.value)}
            style={{padding:"10px 12px", borderRadius:12, border:"1px solid #e5e7eb", minWidth:240}}
          />
          <select value={cat} onChange={e=>setCat(e.target.value)} style={{padding:"10px 12px", borderRadius:12, border:"1px solid #e5e7eb"}}>
            {categories.map(c => <option key={c} value={c}>{c}</option>)}
          </select>
        </div>
      </header>
{/* Download pack button */}
<div style={{marginTop:16, display:"flex", justifyContent:"flex-end"}}>
  <a
    href="/reports/RBIS_DemoReports_Master_Index.pdf"
    target="_blank"
    rel="noopener noreferrer"
    style={{
      textDecoration:"none",
      padding:"10px 14px",
      borderRadius:999,
      background:"#0f172a",
      color:"#fff",
      fontWeight:600,
      border:"1px solid #0f172a"
    }}
  >
    Download demo pack (PDF)
  </a>
</div>


      <section style={{marginTop:24, display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(260px, 1fr))", gap:16}}>
        {filtered.map(r => (
          <article key={r.slug} style={{
            border:"1px solid #e5e7eb",
            borderRadius:16,
            padding:16,
            background:"#fff",
            display:"flex",
            flexDirection:"column",
            gap:10
          }}>
            <div style={{fontSize:12, opacity:.7}}>{r.category}</div>
            <h3 style={{margin:"0 0 4px", lineHeight:1.2}}>{r.title}</h3>
            <div style={{fontSize:13, opacity:.8}}>{r.org}</div>
            {r.summary && <p style={{margin:"6px 0 0", opacity:.9}}>{r.summary}</p>}
            <div style={{marginTop:"auto", display:"flex", justifyContent:"space-between", alignItems:"center", gap:8}}>
              <div style={{fontWeight:700}}>
                {typeof r.priceGBP === "number" ? <>£{r.priceGBP.toFixed(2)}</> : <span style={{opacity:.6}}>Request quote</span>}
              </div>
              <div style={{display:"flex", gap:8}}>
                <a
                  href={`/contact?report=${encodeURIComponent(r.slug)}`}
                  style={{padding:"8px 12px", borderRadius:999, background:"#111827", color:"#fff", textDecoration:"none"}}
                >
                  Enquire
                </a>
                <a
                  href={r.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{padding:"8px 12px", borderRadius:999, border:"1px solid #e5e7eb", textDecoration:"none"}}
                >
                  View PDF
                </a>
              </div>
            </div>
          </article>
        ))}
      </section>

      <footer style={{marginTop:24, fontSize:13, opacity:.7}}>
        Need something bespoke? <a href="/contact">Contact us</a>.
      </footer>
    </main>
  );
}
