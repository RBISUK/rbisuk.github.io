import './evidence.js';
export const data={
    months:['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
    revenue:[58,64,72,69,75,81,88,95,104,110,118,126],
    arr:[300,315,330,345,360,378,396,420,444,468,492,516],
    winRate:[38,42,45,44,47,50,52,53,55,56,57,58],
    opsThroughput:[9,12,14,13,15,16,18,17,19,21,20,22],
    risks:[{name:'Data transfer (US vendor)',L:3,I:4},{name:'Evidence tampering attempt',L:2,I:5},{name:'Vendor outage (analytics)',L:3,I:2},{name:'Credential phishing',L:2,I:4},{name:'Sensitive upload without consent',L:2,I:4}],
    incidents:[{date:'2025-04-12',sev:'Medium',text:'Hotfix applied to malformed email export; no data loss.'},{date:'2025-06-03',sev:'Low',text:'Upstream analytics latency; tracking held until consent renewed.'},{date:'2025-08-18',sev:'High',text:'Attempted credential spray blocked by MFA; audit logged.'}],
    kanban:{intake:['Tenant case: damp/mould','HR dispute: comms audit','Council enquiry: timeline'],analysis:['Audio review: tone markers','Doc auth: timestamp variance'],reporting:['Forensic report: Housing (v1.2)','Compliance memo: Processor review']},
    finance:{marginPct:32,runwayMonths:14}
  };
export const formatGBP = n => '£' + n.toLocaleString('en-GB');
 export function clamp(n,min,max){return Math.max(min,Math.min(max,n))}
 export function sum(a){return a.reduce((x,y)=>x+y,0)}
 export function avg(a){return a.length?sum(a)/a.length:0}
 export function lineChart(id,labels,values,colorA='#3a506b'){const c=document.getElementById(id),ctx=c.getContext('2d');const W=c.clientWidth,H=c.height;c.width=W;ctx.clearRect(0,0,W,H);const pad=28,max=Math.max(...values)*1.15,min=0;ctx.strokeStyle='#e5e7eb';ctx.lineWidth=1;for(let i=0;i<=4;i++){const y=pad+(H-2*pad)*i/4;ctx.beginPath();ctx.moveTo(pad,y);ctx.lineTo(W-pad,y);ctx.stroke();}ctx.lineWidth=2;ctx.strokeStyle=colorA;ctx.beginPath();values.forEach((v,i)=>{const x=pad+(W-2*pad)*(i/(values.length-1));const y=H-pad-((v-min)/(max-min))*(H-2*pad);i?ctx.lineTo(x,y):ctx.moveTo(x,y);});ctx.stroke();const grad=ctx.createLinearGradient(0,pad,0,H-pad);grad.addColorStop(0,'rgba(58,80,107,.25)');grad.addColorStop(1,'rgba(58,80,107,0)');ctx.lineTo(W-pad,H-pad);ctx.lineTo(pad,H-pad);ctx.closePath();ctx.fillStyle=grad;ctx.fill();ctx.fillStyle='#334155';ctx.font='12px system-ui';ctx.fillText(labels[0],pad-6,H-8);ctx.fillText(labels[labels.length-1],W-pad-20,H-8);}
 export function barChart(id,labels,values,color='#118ab2'){const c=document.getElementById(id),ctx=c.getContext('2d');const W=c.clientWidth,H=c.height;c.width=W;ctx.clearRect(0,0,W,H);const pad=28,max=Math.max(...values)*1.2,bw=(W-2*pad)/values.length*.7;values.forEach((v,i)=>{const x=pad+(W-2*pad)*(i/values.length)+(((W-2*pad)/values.length-bw)/2);const h=(v/max)*(H-2*pad);const y=H-pad-h;ctx.fillStyle=color;ctx.fillRect(x,y,bw,h);});ctx.fillStyle='#334155';ctx.font='12px system-ui';ctx.fillText(labels[0],pad-6,H-8);ctx.fillText(labels[labels.length-1],W-pad-20,H-8);}
 export function sparkline(id,values,color='#16a34a'){const c=document.getElementById(id),ctx=c.getContext('2d');const W=c.clientWidth||300,H=c.height;c.width=W;ctx.clearRect(0,0,W,H);const pad=6,max=Math.max(...values),min=Math.min(...values);ctx.strokeStyle=color;ctx.lineWidth=2;ctx.beginPath();values.forEach((v,i)=>{const x=pad+(W-2*pad)*(i/(values.length-1));const y=H-pad-((v-min)/(max-min||1))*(H-2*pad);i?ctx.lineTo(x,y):ctx.moveTo(x,y);});ctx.stroke();}
 export function tone(s){if(s>=16)return 'style="background:#fee2e2"';if(s>=9)return 'style="background:#fef3c7"';return 'style="background:#dcfce7"';}
 export function paintRisk(){const tb=document.querySelector('#riskTable tbody');tb.innerHTML='';data.risks.forEach(r=>{const score=r.L*r.I;const tr=document.createElement('tr');tr.innerHTML=`<td>${r.name}</td><td>${r.L}/5</td><td>${r.I}/5</td><td ${tone(score)}><b>${score}</b></td>`;tb.appendChild(tr);});const ul=document.getElementById('incidents');ul.innerHTML='';data.incidents.forEach(i=>{const c=i.sev==='High'? 'var(--bad)':i.sev==='Medium'? 'var(--warn)':'var(--ok)';const li=document.createElement('li');li.innerHTML=`<span style="color:${c};font-weight:700">${i.sev}</span> — ${i.date} — ${i.text}`;ul.appendChild(li);});}
 export function paintKanban(){const {intake,analysis,reporting}=data.kanban;const fill=(id,arr)=>{const ul=document.getElementById(id);ul.innerHTML='';arr.forEach(x=>{const li=document.createElement('li');li.textContent=x;ul.appendChild(li);});};fill('listIntake',intake);fill('listAnalysis',analysis);fill('listReporting',reporting);document.getElementById('kIntake').textContent=intake.length;document.getElementById('kAnalysis').textContent=analysis.length;document.getElementById('kReporting').textContent=reporting.length;}
export let currentPeriod='YTD';
 export function sliceFor(p){const idx={Q1:[0,3],Q2:[3,6],Q3:[6,9],Q4:[9,12],YTD:[0,new Date().getMonth()+1]};const [s,e]=idx[p];return{months:data.months.slice(s,e),revenue:data.revenue.slice(s,e),arr:data.arr.slice(s,e),winRate:data.winRate.slice(s,e),opsThroughput:data.opsThroughput.slice(s,e)};}
 export function setPeriod(p){currentPeriod=p;render();} window.setPeriod=setPeriod;
export function render(){
  const d = sliceFor(currentPeriod);
  if(!d.months.length){
    document.getElementById("nodata").style.display="block";
    document.querySelectorAll(".section").forEach(s=>s.style.display="none");
    return;
  } else {
    document.getElementById("nodata").style.display="none";
    document.querySelectorAll(".section").forEach(s=>s.style.display="");
  }
  const revK=sum(d.revenue)*1000, arrK=d.arr[d.arr.length-1]*1000, winK=avg(d.winRate);
  document.getElementById("kpiRevenue").textContent=formatGBP(revK);
  document.getElementById("kpiARR").textContent=formatGBP(arrK);
  document.getElementById("kpiWin").textContent=Math.round(winK)+"%";
  document.getElementById("gRevenue").style.width=clamp((revK/(sum(data.revenue)*1000))*100,5,100)+"%";
  document.getElementById("gARR").style.width=clamp((arrK/(data.arr[data.arr.length-1]*1000))*100,5,100)+"%";
  document.getElementById("gWin").style.width=clamp(winK,5,100)+"%";
  const arrGrowth=((d.arr[d.arr.length-1]-d.arr[0])/Math.max(d.arr[0],1))*100;
  document.getElementById("kARRg").textContent=(arrGrowth>0?"+":"")+Math.round(arrGrowth)+"%";
  document.getElementById("kMargin").textContent=data.finance.marginPct+"%";
  document.getElementById("kRunway").textContent=data.finance.runwayMonths+" mo";
  lineChart("chartRevenue", d.months, d.revenue);
  barChart("chartARR", d.months, d.arr);
  barChart("chartOps", d.months, d.opsThroughput, "#1c2541");
  sparkline("spark1", data.revenue);
}

 export function exportCSV(){const d=sliceFor(currentPeriod);const lines=[];const now=new Date().toISOString();const pushTable=(title,headers,rows)=>{lines.push('# '+title);lines.push(headers.join(','));rows.forEach(r=>lines.push(r.map(x=>(''+x).replaceAll(',', ';')).join(',')));lines.push('');};pushTable(`Revenue (£k) — Period ${currentPeriod} — Issued ${now}`,['Month','Revenue_k'],d.months.map((m,i)=>[m,d.revenue[i]]));pushTable(`ARR (£k) — Period ${currentPeriod} — Issued ${now}`,['Month','ARR_k'],d.months.map((m,i)=>[m,d.arr[i]]));pushTable(`WinRate (%) — Period ${currentPeriod} — Issued ${now}`,['Month','WinRate_pct'],d.months.map((m,i)=>[m,d.winRate[i]]));pushTable(`Ops Throughput (cases closed) — Period ${currentPeriod} — Issued ${now}`,['Month','Closed'],d.months.map((m,i)=>[m,d.opsThroughput[i]]));pushTable('Risk Register (LxI score)',['Risk','Likelihood_1to5','Impact_1to5','Score'],data.risks.map(r=>[r.name,r.L,r.I,r.L*r.I]));pushTable('Incidents Timeline',['Date','Severity','Summary'],data.incidents.map(i=>[i.date,i.sev,i.text]));const blob=new Blob([lines.join('\n')],{type:'text/csv'});const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download=`RBIS_Dashboard_${currentPeriod}_${now.substring(0,10)}.csv`;document.body.appendChild(a);a.click();URL.revokeObjectURL(url);a.remove();}
 export function printEvidencePack(){render();function snap(id){const c=document.getElementById(id);return c?c.toDataURL('image/png'):'';}const imgRevenue=snap('chartRevenue'),imgARR=snap('chartARR'),imgOps=snap('chartOps'),imgSpark=snap('spark1');const now=new Date().toISOString();const html=`<!doctype html><html><head><meta charset="utf-8"/><title>RBIS Evidence Pack — ${currentPeriod} — ${now}</title><style>body{font-family:ui-sans-serif,system-ui;margin:24px;color:#0f172a}h1{margin:0 0 6px}h2{margin:18px 0 8px}h3{margin:12px 0 6px}.muted{color:#475569}.kpis{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}.kpi{border:1px solid #e5e7eb;border-radius:12px;padding:10px}img{max-width:100%;height:auto;border:1px solid #e5e7eb;border-radius:8px}table{width:100%;border-collapse:collapse;margin-top:8px}th,td{border:1px solid #e5e7eb;padding:8px;text-align:left;vertical-align:top}@media print{.page{page-break-after:always}a:after{content:" (" attr(href) ")";font-size:11px;color:#64748b}}</style></head><body><h1>RBIS Evidence Pack</h1><p class="muted">Period: <b>${currentPeriod}</b> • Issued: ${now} • Source: dashboards.html</p><div class="kpis"><div class="kpi"><div class="muted">Revenue (YTD)</div><div style="font-weight:700;font-size:20px">${document.getElementById('kpiRevenue').textContent}</div></div><div class="kpi"><div class="muted">ARR</div><div style="font-weight:700;font-size:20px">${document.getElementById('kpiARR').textContent}</div></div><div class="kpi"><div class="muted">Win Rate</div><div style="font-weight:700;font-size:20px">${document.getElementById('kpiWin').textContent}</div></div></div><div class="page"><h2>Charts</h2><h3>Revenue</h3><img alt="Revenue chart" src="${imgRevenue}"/><h3>ARR</h3><img alt="ARR chart" src="${imgARR}"/><h3>Ops Throughput</h3><img alt="Ops chart" src="${imgOps}"/><h3>CEO Sparkline</h3><img alt="Sparkline" src="${imgSpark}"/></div><div class="page"><h2>Risk Register</h2><table><thead><tr><th>Risk</th><th>Likelihood</th><th>Impact</th><th>Score</th></tr></thead><tbody>${data.risks.map(r=>`<tr><td>${r.name}</td><td>${r.L}/5</td><td>${r.I}/5</td><td><b>${r.L*r.I}</b></td></tr>`).join('')}</tbody></table><h2>Incidents</h2><table><thead><tr><th>Date</th><th>Severity</th><th>Summary</th></tr></thead><tbody>${data.incidents.map(i=>`<tr><td>${i.date}</td><td>${i.sev}</td><td>${i.text}</td></tr>`).join('')}</tbody></table></div><div><h2>Statement</h2><p>RBIS applies court-ready standards to intake, chain of custody, and analyst review. See <a href="trust.html">Trust Centre</a> and <a href="legal.html">Legal Hub</a>. This pack is a representation of current dashboards for the chosen period and is intended to support— not substitute—qualified legal advice.</p></div></body></html>`;const w=window.open('about:blank');w.document.write(html);w.document.close();}
window.exportCSV=exportCSV;
window.printEvidencePack=printEvidencePack;
paintRisk();paintKanban();setPeriod('YTD');
