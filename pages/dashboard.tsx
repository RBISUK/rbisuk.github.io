import Head from "next/head";
import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";

type Point = { t: number; v: number };
type Alert = { id: string; severity: "low"|"med"|"high"; title: string; detail: string; when: string };

const s = {
  page: { fontFamily: "system-ui", color: "#111" } as React.CSSProperties,
  wrap: { padding: "2rem", lineHeight: 1.55, maxWidth: 1200, margin: "0 auto" } as React.CSSProperties,
  hero: { display: "flex", justifyContent: "space-between", gap: 16, flexWrap: "wrap" } as React.CSSProperties,
  h1: { margin: 0, fontSize: 32, lineHeight: 1.15 } as React.CSSProperties,
  hint: { color: "#666" } as React.CSSProperties,
  grid: { display: "grid", gap: 16, gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))", marginTop: 16 } as React.CSSProperties,
  card: { border: "1px solid #eee", borderRadius: 12, padding: 16, background: "#fff" } as React.CSSProperties,
  kpi: { display: "grid", gap: 6 } as React.CSSProperties,
  kpiLabel: { fontSize: 13, color: "#666" } as React.CSSProperties,
  kpiValue: { fontSize: 28, fontWeight: 800 } as React.CSSProperties,
  kpiSub: { fontSize: 12, color: "#444" } as React.CSSProperties,
  panel: { display: "grid", gap: 12, gridTemplateColumns: "1.2fr 1fr", alignItems: "stretch" } as React.CSSProperties,
  panelCol: { display: "grid", gap: 16 } as React.CSSProperties,
  table: { width: "100%", borderCollapse: "collapse", fontSize: 14 } as React.CSSProperties,
  th: { textAlign: "left", borderBottom: "1px solid #eee", padding: "10px 8px", color: "#555" } as React.CSSProperties,
  td: { borderBottom: "1px solid #f3f3f3", padding: "10px 8px" } as React.CSSProperties,
  badge: (sev: Alert["severity"]) => ({
    display: "inline-block", padding: "2px 8px", borderRadius: 999,
    background: sev==="high"?"#ffe5e5":sev==="med"?"#fff5d6":"#eef7ff",
    color: sev==="high"?"#8c0000":sev==="med"?"#8a5a00":"#0a3a8a", fontSize: 12
  }) as React.CSSProperties,
  priceGrid: { display: "grid", gap: 16, gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))" } as React.CSSProperties,
  priceCard: { position: "relative", border: "1px solid #e9e9e9", borderRadius: 14, padding: 20, background: "#fff" } as React.CSSProperties,
  ribbon: { position: "absolute", top: 10, right: -6, background: "#111", color: "#fff", padding: "4px 12px", borderRadius: 999, fontSize: 12 } as React.CSSProperties,
  priceBig: { fontWeight: 800, fontSize: 22 } as React.CSSProperties,
  priceSmall: { color: "#444" } as React.CSSProperties,
  btnRow: { display: "flex", gap: 12, flexWrap: "wrap", marginTop: 12 } as React.CSSProperties,
  btn: { padding: "10px 14px", borderRadius: 10, border: "1px solid #111", textDecoration: "none" } as React.CSSProperties,
  subnote: { fontSize: 12, color: "#666" } as React.CSSProperties,
};

function fmt(n:number){ return n.toLocaleString("en-GB"); }
function pct(n:number){ const sign = n>0?"+":""; return `${sign}${(n*100).toFixed(1)}%`; }
function rng(seed:number){ let s=seed|0; return ()=> (s=(s*1664525+1013904223)%4294967296)/4294967296; }

export default function Dashboard(){
  const [mounted, setMounted] = useState(false);
  useEffect(()=>{ setMounted(true); },[]);

  const [tick, setTick] = useState(0);
  const dataRef = useRef<{vol:Point[]; sla:Point[]}>({ vol:[], sla:[] });
  const alertsRef = useRef<Alert[]>([]);

  useEffect(()=>{
    if(!mounted) return;
    const base = Date.now()-1000*60*60*24;
    const r = rng(42);
    const pts: Point[] = []; const sla: Point[] = [];
    let v = 120; let s = 0.12;
    for(let i=0;i<48;i++){
      v = Math.max(40, v + Math.round((r()-0.5)*20));
      s = Math.min(0.40, Math.max(0.02, s + (r()-0.5)*0.03));
      pts.push({ t: base + i*30*60*1000, v });
      sla.push({ t: base + i*30*60*1000, v: s });
    }
    dataRef.current = { vol: pts, sla };
    alertsRef.current = seedAlerts();
    setTick(x=>x+1);
  },[mounted]);

  useEffect(()=>{
    if(!mounted) return;
    const h = setInterval(()=>{
      const r = rng(Math.floor(Date.now()/3000));
      roll(dataRef.current, r);
      maybeAlert(alertsRef);
      setTick(x=>x+1);
    }, 3000);
    return ()=>clearInterval(h);
  },[mounted]);

  const kpis = useMemo(()=>{
    const vol = dataRef.current.vol, sla = dataRef.current.sla;
    if(!vol.length) return { today:0, change:0, slaNow:0, fcr:0.0 };
    const latest = vol[vol.length-1].v;
    const prev = vol[Math.max(0, vol.length-5)].v;
    const change = (latest-prev)/Math.max(1, prev);
    const slaNow = sla[sla.length-1].v;
    const fcr = 0.72 + ((latest%13)-6)/100;
    return { today: latest, change, slaNow, fcr: Math.max(0.45, Math.min(0.95, fcr)) };
  },[tick]);

  const alerts = useMemo(()=>alertsRef.current.slice(-7).reverse(),[tick]);

  return (
    <>
      <Head>
        <title>RBIS Dashboard — Live Preview</title>
        <meta name="description" content="Live-feel intake analytics, SLA risk and compliance alerts. Transparent packages with simple pricing and £250/mo IT & Web Support."/>
      </Head>

      <div style={s.page}>
        <main style={s.wrap}>
          <div style={s.hero}>
            <div>
              <h1 style={s.h1}>RBIS Dashboard</h1>
              <p style={s.hint}>Real-time intake health, SLA risk, and compliance signals. Client-safe, audit-ready.</p>
              <div style={s.btnRow}>
                <Link href="/contact?intent=dashboard-demo" style={s.btn}>Request a demo</Link>
                <Link href="/trust-centre" style={s.btn}>See compliance details</Link>
              </div>
            </div>
            <div className="clock" aria-live="polite" style={{alignSelf:"center", fontVariantNumeric:"tabular-nums"}}>
              {mounted ? new Date().toLocaleString("en-GB") : "—"}
            </div>
          </div>

          <section style={{marginTop:16}}>
            <div style={s.grid}>
              <div style={s.card}><div style={s.kpi}>
                <span style={s.kpiLabel}>Today’s intake volume</span>
                <span style={s.kpiValue}>{fmt(kpis.today)}</span>
                <span style={s.kpiSub}>{pct(kpis.change)} vs last hour</span>
              </div></div>
              <div style={s.card}><div style={s.kpi}>
                <span style={s.kpiLabel}>SLA risk (next 24h)</span>
                <span style={s.kpiValue}>{Math.round(kpis.slaNow*100)}%</span>
                <span style={s.kpiSub}>Includes backlog & velocity</span>
              </div></div>
              <div style={s.card}><div style={s.kpi}>
                <span style={s.kpiLabel}>First-contact resolution</span>
                <span style={s.kpiValue}>{Math.round(kpis.fcr*100)}%</span>
                <span style={s.kpiSub}>Behavioural prompts reduce rework</span>
              </div></div>
              <div style={s.card}><div style={s.kpi}>
                <span style={s.kpiLabel}>Accessibility score</span>
                <span style={s.kpiValue}>98</span>
                <span style={s.kpiSub}>WCAG 2.1 AA checks (Lighthouse)</span>
              </div></div>
            </div>
          </section>

          <section style={{marginTop:16}}>
            {mounted ? (
              <div style={s.panel}>
                <div style={s.panelCol}>
                  <ChartLine title="Intake Volume (last 24h)" points={dataRef.current.vol} minY={0} maxY={Math.max(150, maxY(dataRef.current.vol)*1.2)} />
                  <ChartBars title="SLA Risk Forecast (next 24h)" points={projectSLA(dataRef.current.sla)} minY={0} maxY={1} />
                </div>
                <div style={s.card}>
                  <h3 style={{marginTop:0}}>Live alerts</h3>
                  <table style={s.table}>
                    <thead><tr><th style={s.th}>Severity</th><th style={s.th}>Alert</th><th style={s.th}>When</th></tr></thead>
                    <tbody>
                      {alerts.map(a=>(
                        <tr key={a.id}>
                          <td style={s.td}><span style={s.badge(a.severity)}>{a.severity.toUpperCase()}</span></td>
                          <td style={s.td}><b>{a.title}</b><div style={{color:"#555"}}>{a.detail}</div></td>
                          <td style={s.td} aria-label={`at ${a.when}`}>{a.when}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                  <div style={{marginTop:8}}>
                    <span style={s.subnote}>Auditability: alerts are retained 90 days in the system log. Export available on Pro+.</span>
                  </div>
                </div>
              </div>
            ) : (
              <div style={{...s.card, textAlign:"center"}}>Loading live tiles…</div>
            )}
          </section>

          <section style={{marginTop:24}}>
            <h2 style={{margin:"0 0 8px"}}>Packages & pricing</h2>
            <p style={s.hint}>Simple pricing. Every package includes <b>£250/mo IT &amp; Web Support</b> for updates, security, and compliance monitoring.</p>
            <div style={s.priceGrid}>
              {[
                {
                  name:"Starter",
                  pitch:"Core metrics, daily email summary, CSV export.",
                  setup:"£750", support:"£250/mo",
                  items:["Intake volume + trends","Basic SLA risk meter","CSV export"],
                  cta:["/contact?intent=dashboard-starter","Get Starter"],
                  ribbon:""
                },
                {
                  name:"Pro",
                  pitch:"Behavioural insights, alerting, weekly compliance snapshot.",
                  setup:"£1,450", support:"£250/mo",
                  items:["All Starter features","Live alerts & thresholds","Consent split & Lighthouse tiles","Scheduled PDF snapshot"],
                  cta:["/contact?intent=dashboard-pro","Get Pro"],
                  ribbon:"Recommended"
                },
                {
                  name:"Enterprise",
                  pitch:"Custom KPIs, PACT integration, role-based dashboards.",
                  setup:"£4,900", support:"£250/mo",
                  items:["All Pro features","PACT Ledger timeline tiles","Role-based access & SSO ready","Quarterly RBIS Certified check"],
                  cta:["/contact?intent=dashboard-enterprise","Talk to sales"],
                  ribbon:""
                }
              ].map((pkg,i)=>(
                <div key={i} style={{...s.priceCard, ...(pkg.ribbon?{border:"2px solid #111"}:{})}} className="rbis-card">
                  {pkg.ribbon && <div style={s.ribbon}>{pkg.ribbon}</div>}
                  <h3 style={{marginTop:0}}>{pkg.name}</h3>
                  <p>{pkg.pitch}</p>
                  <ul style={{margin:"8px 0 0 18px"}}>
                    {pkg.items.map((it,j)=>(<li key={j}>{it}</li>))}
                  </ul>
                  <div style={{display:"flex", gap:8, alignItems:"baseline", marginTop:10}}>
                    <span style={s.priceBig}>{pkg.setup}</span><span style={s.priceSmall}>setup</span>
                    <span style={s.priceBig}>{pkg.support}</span><span style={s.priceSmall}> support</span>
                  </div>
                  <div style={s.btnRow}><Link href={pkg.cta[0]} style={s.btn}>{pkg.cta[1]}</Link></div>
                </div>
              ))}
            </div>
            <p style={{marginTop:8, ...s.subnote}}>
              Optional add-ons: OmniAssist Automation £750 setup + £250/mo, NextusOne CRM licences from £15/user/mo + £250/mo support.
            </p>
          </section>
        </main>
      </div>

      <style>{`
        .rbis-card { transition: transform .15s ease, box-shadow .15s ease; }
        .rbis-card:hover, .rbis-card:focus-within { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(0,0,0,.06); }
        .clock { font-size: 14px; color: #444 }
        @media (prefers-reduced-motion: reduce) { .rbis-card { transition: none; } }
      `}</style>
    </>
  );
}

function ChartLine({ title, points, minY, maxY }:{ title:string; points:Point[]; minY:number; maxY:number; }){
  const w=600, h=220, pad=28;
  const xs = (t:number)=>{ const lo=points[0]?.t??0, hi=points[points.length-1]?.t??1; return pad + ((t-lo)/(hi-lo||1))*(w-pad*2); };
  const ys = (v:number)=> h - pad - ((v-minY)/(maxY-minY||1))*(h-pad*2);
  const d = points.map((p,i)=> `${i?"L":"M"}${xs(p.t)},${ys(p.v)}`).join(" ");
  const last = points[points.length-1];
  return (
    <div style={{border:"1px solid #eee",borderRadius:12,padding:12,background:"#fff"}}>
      <div style={{margin:"4px 8px 8px",fontSize:14,color:"#444"}}>{title}</div>
      <svg viewBox={`0 0 ${w} ${h}`} width="100%" height="220" role="img" aria-label={title}>
        <rect x="0" y="0" width={w} height={h} fill="#fff"/>
        {Array.from({length:5}).map((_,i)=>(<line key={i} x1={pad} x2={w-pad} y1={pad+i*((h-pad*2)/4)} y2={pad+i*((h-pad*2)/4)} stroke="#f0f0f0"/>))}
        <path d={d} fill="none" stroke="#111" strokeWidth="2"/>
        {last && <circle cx={xs(last.t)} cy={ys(last.v)} r="3" fill="#111" />}
      </svg>
    </div>
  );
}
function ChartBars({ title, points, minY, maxY }:{ title:string; points:Point[]; minY:number; maxY:number; }){
  const w=600, h=220, pad=28;
  const barW = ((w-pad*2)/points.length)*0.7;
  return (
    <div style={{border:"1px solid #eee",borderRadius:12,padding:12,background:"#fff"}}>
      <div style={{margin:"4px 8px 8px",fontSize:14,color:"#444"}}>{title}</div>
      <svg viewBox={`0 0 ${w} ${h}`} width="100%" height="220" role="img" aria-label={title}>
        <rect x="0" y="0" width={w} height={h} fill="#fff"/>
        {points.map((p, i)=>{
          const x = pad + i*((w-pad*2)/points.length);
          const hh = ((p.v-minY)/(maxY-minY||1))*(h-pad*2);
          const y = h-pad-hh;
          return <rect key={i} x={x} y={y} width={barW} height={hh} fill="#111" />;
        })}
      </svg>
    </div>
  );
}
function maxY(pts:Point[]){ return pts.reduce((m,p)=>Math.max(m,p.v), 0); }
function roll(store:{vol:Point[]; sla:Point[]}, r:()=>number){
  const step = 30*60*1000;
  const lastT = store.vol[store.vol.length-1]?.t ?? Date.now();
  let lastV = store.vol[store.vol.length-1]?.v ?? 100;
  let lastS = store.sla[store.sla.length-1]?.v ?? 0.12;
  lastV = Math.max(30, lastV + Math.round((r()-0.5)*18));
  lastS = Math.min(0.40, Math.max(0.02, lastS + (r()-0.5)*0.025));
  store.vol = [...store.vol.slice(1), { t: lastT+step, v: lastV }];
  store.sla = [...store.sla.slice(1), { t: lastT+step, v: lastS }];
}
function projectSLA(sla:Point[]){
  const N = Math.min(12, sla.length);
  const tail = sla.slice(-N);
  const step = 30*60*1000;
  const base = sla[sla.length-1]?.t ?? Date.now();
  return Array.from({length:N}, (_,i)=>({ t: base+(i+1)*step, v: tail[i].v }));
}
function seedAlerts(): Alert[] {
  const now = Date.now();
  return [
    { id:"a1", severity:"high", title:"SLA breach risk ↑", detail:"Veridex queue trending high vs capacity", when:new Date(now-2*60*60*1000).toLocaleTimeString("en-GB") },
    { id:"a2", severity:"med", title:"Consent split missing", detail:"2 forms skipped marketing checkbox", when:new Date(now-65*60*1000).toLocaleTimeString("en-GB") },
    { id:"a3", severity:"low", title:"Lighthouse dip", detail:"Accessibility 94 → 90 (contrast)", when:new Date(now-48*60*1000).toLocaleTimeString("en-GB") },
  ];
}
function maybeAlert(ref: React.MutableRefObject<Alert[]>) {
  if (Math.random() < 0.33) {
    const sev: Alert["severity"] = Math.random()<0.2?"high":(Math.random()<0.6?"med":"low");
    const id = Math.random().toString(36).slice(2);
    ref.current = [...ref.current, {
      id, severity: sev,
      title: sev==="high"?"Queue spike detected": sev==="med"?"Threshold crossed":"Minor variability",
      detail: sev==="high"?"Backlog growth outpacing capacity":"Metric drift within watch range",
      when: new Date().toLocaleTimeString("en-GB")
    }];
  }
}
