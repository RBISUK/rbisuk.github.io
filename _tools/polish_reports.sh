#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ ERR line $LINENO: $BASH_COMMAND" >&2' ERR

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
f_html="reports.html"
f_css="assets/rbis.css"
f_js="assets/rbis.js"

test -f "$f_html" || { echo "✖ $f_html missing"; exit 1; }
mkdir -p assets _backups

cp -f "$f_html"        "_backups/reports.html.$STAMP"
cp -f "$f_css"         "_backups/rbis.css.$STAMP" 2>/dev/null || true
cp -f "$f_js"          "_backups/rbis.js.$STAMP"  2>/dev/null || true

# --- CSS (only append once) ---
if ! grep -q '/* RBIS Reports grid */' "$f_css" 2>/dev/null; then
  cat >> "$f_css" <<'CSS'

/* RBIS Reports grid */
.rbis-wrap{max-width:1160px;margin:0 auto;padding:0 20px}
.r-headline{display:flex;justify-content:space-between;align-items:end;gap:16px;margin:10px 0 18px}
.r-headline h2{font-size:28px;margin:0}
.r-headline p{margin:0;color:var(--muted)}
.rgrid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:18px}
.r-card{background:var(--panel);border:1px solid rgba(255,255,255,.07);border-radius:16px;box-shadow:var(--shadow);padding:18px;display:flex;flex-direction:column;gap:10px}
.r-card h3{margin:8px 0 2px;font-size:18px}
.r-copy{color:var(--muted);margin:0}
.r-top{display:flex;align-items:center;gap:10px}
.r-ico{width:28px;height:28px;display:inline-grid;place-items:center;background:linear-gradient(180deg,#9ae7ff,#7cc4ff);border-radius:10px;box-shadow:0 4px 16px rgba(124,196,255,.35)}
.r-price{font-weight:600}
.r-tags{display:flex;gap:8px;flex-wrap:wrap}
.r-tag{font-size:12px;padding:4px 8px;border-radius:999px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.08)}
.r-foot{display:flex;align-items:center;justify-content:space-between;gap:10px;margin-top:auto}
.r-foot .btn{padding:10px 12px;border-radius:12px;background:#6bf;color:#071018;font-weight:700;border:none;cursor:pointer}
.r-foot .btn:hover{filter:brightness(1.05)}
/* Drawer */
.r-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.5);backdrop-filter:blur(6px);opacity:0;pointer-events:none;transition:opacity .2s ease}
.r-backdrop.open{opacity:1;pointer-events:auto}
.r-drawer{position:fixed;left:50%;bottom:-100%;transform:translateX(-50%);width:min(920px,94vw);max-height:80vh;overflow:auto;background:var(--panel);border:1px solid rgba(255,255,255,.08);border-radius:20px 20px 12px 12px;box-shadow:0 18px 60px rgba(0,0,0,.45);transition:bottom .22s ease}
.r-drawer.open{bottom:22px}
.r-dw-head{display:flex;justify-content:space-between;align-items:center;padding:16px 18px;border-bottom:1px solid rgba(255,255,255,.08)}
.r-dw-body{padding:18px}
.r-dw-meta{display:flex;gap:14px;flex-wrap:wrap;margin:6px 0 12px}
.r-kv{font-size:14px;color:var(--muted)}
.r-kv strong{color:var(--ink)}
.r-bullets{margin:0 0 10px 18px}
.r-close{background:none;border:none;color:var(--ink);font-size:20px;cursor:pointer;opacity:.85}
.r-close:hover{opacity:1}
CSS
fi

# --- JS (only append once) ---
if ! grep -q '/* RBIS Reports drawer */' "$f_js" 2>/dev/null; then
  cat >> "$f_js" <<'JS'

/* RBIS Reports drawer */
(() => {
  const $ = (s, r=document) => r.querySelector(s);
  const $$= (s, r=document) => [...r.querySelectorAll(s)];
  const backdrop = document.getElementById('report-backdrop');
  const drawer   = document.getElementById('report-drawer');
  const titleEl  = document.getElementById('rd-title');
  const priceEl  = document.getElementById('rd-price');
  const timeEl   = document.getElementById('rd-time');
  const copyEl   = document.getElementById('rd-copy');
  const listEl   = document.getElementById('rd-list');

  function openDrawer(data){
    if(!drawer) return;
    titleEl.textContent = data.title || 'Report';
    priceEl.textContent = data.price || '';
    timeEl.textContent  = data.time  || '';
    copyEl.textContent  = data.summary || '';
    listEl.innerHTML = '';
    (data.bullets||[]).forEach(b=>{
      const li = document.createElement('li'); li.textContent = b; listEl.appendChild(li);
    });
    backdrop.classList.add('open');
    drawer.classList.add('open');
  }
  function closeDrawer(){
    backdrop.classList.remove('open');
    drawer.classList.remove('open');
  }

  document.addEventListener('click', (e)=>{
    const btn = e.target.closest('.r-open');
    if(btn){
      const card = btn.closest('.r-card');
      const data = {
        title:   card?.dataset.title,
        price:   card?.dataset.price,
        time:    card?.dataset.time,
        summary: card?.dataset.summary,
        bullets: (card?.dataset.bullets || '').split('|').filter(Boolean)
      };
      openDrawer(data);
    }
    if(e.target.closest('.r-close') || e.target === backdrop){ closeDrawer(); }
  });

  window.addEventListener('keydown', (e)=>{ if(e.key === 'Escape') closeDrawer() });
})();
JS
fi

# --- Drawer skeleton (only once) ---
if ! grep -q 'id="report-drawer"' "$f_html"; then
  awk -v RS= -v ORS= '
    /<\/body>/ && !done {
      done=1
      print "<div class=\"r-backdrop\" id=\"report-backdrop\"></div>"
      print "<section class=\"r-drawer\" id=\"report-drawer\" role=\"dialog\" aria-modal=\"true\" aria-labelledby=\"rd-title\">"
      print "  <div class=\"r-dw-head\">"
      print "    <h3 id=\"rd-title\" style=\"margin:0\">Report</h3>"
      print "    <button class=\"r-close\" aria-label=\"Close\">✕</button>"
      print "  </div>"
      print "  <div class=\"r-dw-body rbis-wrap\">"
      print "    <div class=\"r-dw-meta\">"
      print "      <span class=\"r-kv\"><strong id=\"rd-price\"></strong> • price</span>"
      print "      <span class=\"r-kv\"><strong id=\"rd-time\"></strong> • turnaround</span>"
      print "    </div>"
      print "    <p id=\"rd-copy\" class=\"r-copy\"></p>"
      print "    <ul id=\"rd-list\" class=\"r-bullets\"></ul>"
      print "    <p><a class=\"btn\" href=\"/contact.html?utm_source=site&utm_medium=cta&utm_campaign=reports\">Request this report</a></p>"
      print "  </div>"
      print "</section>"
      print
      next
    }1' "$f_html" > .tmp && mv .tmp "$f_html"
fi

# --- Grid section (insert once, keep old content below) ---
if ! grep -q 'id="reports-grid"' "$f_html"; then
  cat > .rbis_grid_block.tmp <<'HTML'
<section id="reports-grid" class="section">
  <div class="rbis-wrap">
    <div class="r-headline">
      <div>
        <h2>Professional Reports</h2>
        <p>Evidence you can trust — clear, defensible, and fast. Click any report to view details.</p>
      </div>
      <p><a href="/dashboard.html" class="btn" style="background:linear-gradient(180deg,#9ae7ff,#7cc4ff);color:#071018">View live metrics</a></p>
    </div>

    <div class="rgrid">

      <article class="r-card"
        data-title="Housing Disrepair Claim Review"
        data-price="from £495"
        data-time="2–5 days"
        data-summary="Independent review of claim, chronology, evidence quality and likely uphold exposure."
        data-bullets="Chronology check|Defect taxonomy & severity|Evidence completeness score|Uphold risk cues">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M12 2 3 7v10l9 5 9-5V7z"/></svg>
          </span>
          <h3>Disrepair Claim Review</h3>
        </div>
        <p class="r-copy">Audit-ready assessment of case strength with breach flags and next steps.</p>
        <div class="r-foot">
          <span class="r-price">from £495</span>
          <button class="btn r-open">View details</button>
        </div>
      </article>

      <article class="r-card"
        data-title="Timeline Consistency Report"
        data-price="from £395"
        data-time="1–3 days"
        data-summary="Compare stated events vs. artefacts to surface gaps, overlaps, and conflicts."
        data-bullets="Event map|Gap detection|External corroboration|Exportable timeline">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M4 12h16v2H4zm0-6h16v2H4zm0 12h16v2H4z"/></svg>
          </span>
          <h3>Timeline Consistency</h3>
        </div>
        <p class="r-copy">Conflicts resolved; a single source of truth you can hand to legal or board.</p>
        <div class="r-foot"><span class="r-price">from £395</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Communications Credibility Analysis"
        data-price="from £595"
        data-time="2–4 days"
        data-summary="Behavioural & tone analysis of emails/calls to assess consistency and credibility."
        data-bullets="Tone & sentiment signals|Inconsistency cues|Escalation triggers|Evidence excerpts">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M4 4h16v12H5.17L4 17.17V4zM6 20v-2h12v2H6z"/></svg>
          </span>
          <h3>Credibility Analysis</h3>
        </div>
        <p class="r-copy">Move from vibes to verified: language cues with context and examples.</p>
        <div class="r-foot"><span class="r-price">from £595</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Forensic Document & Image Audit"
        data-price="from £650"
        data-time="3–5 days"
        data-summary="Authenticity checks for key artefacts; detect edits, metadata anomalies, mismatch."
        data-bullets="EXIF & hash checks|Clone detection|Metadata timeline|Tamper likelihood">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M12 4 2 20h20L12 4z"/></svg>
          </span>
          <h3>Forensic Audit</h3>
        </div>
        <p class="r-copy">Trust what you file. Clear pass/fail with rationale and references.</p>
        <div class="r-foot"><span class="r-price">from £650</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Fraud Pattern & Risk Indicators"
        data-price="from £795"
        data-time="3–6 days"
        data-summary="Pattern analysis across claims to flag anomalies and potential abuse."
        data-bullets="Outlier scoring|Network & repeat signals|Selector drift|Policy gaps">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M3 13h2v8H3zm8-8h2v16h-2zM19 9h2v12h-2z"/></svg>
          </span>
          <h3>Fraud Pattern Check</h3>
        </div>
        <p class="r-copy">Focus scarce time where risk and impact are highest.</p>
        <div class="r-foot"><span class="r-price">from £795</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Contractor Claim & Invoice Audit"
        data-price="from £795"
        data-time="3–6 days"
        data-summary="Cross-check scopes, timesheets, invoices and outcomes for variance and leakage."
        data-bullets="Scope vs. outcome|Rate sanity|Repeat & rework|Evidence links">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M3 4h18v4H3zM3 10h10v10H3zM15 10h6v10h-6z"/></svg>
          </span>
          <h3>Contractor Audit</h3>
        </div>
        <p class="r-copy">Leakage closed; governance demonstrated.</p>
        <div class="r-foot"><span class="r-price">from £795</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Ombudsman / Board Pack QA"
        data-price="from £495"
        data-time="2–4 days"
        data-summary="Ensure submissions are complete, consistent and breach-aware before you send."
        data-bullets="Completeness map|Breach flags|Redactions|Export pack">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M5 4h14v2H5zm0 4h14v10H5z"/></svg>
          </span>
          <h3>Pack QA</h3>
        </div>
        <p class="r-copy">Save rounds of queries; show your homework.</p>
        <div class="r-foot"><span class="r-price">from £495</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Workplace Dispute Behavioural Brief"
        data-price="from £695"
        data-time="3–5 days"
        data-summary="Independent behavioural read of communications to guide fair outcomes."
        data-bullets="Consistency profile|Escalation cues|Risk map|Suggested next actions">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M12 2a7 7 0 0 1 7 7c0 5-7 13-7 13S5 14 5 9a7 7 0 0 1 7-7z"/></svg>
          </span>
          <h3>Workplace Behaviour Brief</h3>
        </div>
        <p class="r-copy">Clarity without bias. Defensible and practical.</p>
        <div class="r-foot"><span class="r-price">from £695</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Voice & Tone Analysis (Calls)"
        data-price="from £550"
        data-time="2–4 days"
        data-summary="Paralinguistic and transcript cues to spot pressure, coaching, or escalation."
        data-bullets="Stress/tension markers|Turn-taking & dominance|Consistency vs. claims|Excerpts">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M7 4h10v16H7z"/></svg>
          </span>
          <h3>Voice & Tone</h3>
        </div>
        <p class="r-copy">Go beyond words; hear what’s really happening.</p>
        <div class="r-foot"><span class="r-price">from £550</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Incident After-Action Review"
        data-price="from £995"
        data-time="5–10 days"
        data-summary="Neutral, evidence-based review with corrective actions and ownership."
        data-bullets="What/why timeline|Control gaps|Action owners|Board summary">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M4 4h16v4H4zm0 6h10v4H4zm0 6h16v4H4z"/></svg>
          </span>
          <h3>After-Action Review</h3>
        </div>
        <p class="r-copy">Fix causes, not symptoms. Ready for board.</p>
        <div class="r-foot"><span class="r-price">from £995</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Board Risk & Controls Brief"
        data-price="from £1,250"
        data-time="5–10 days"
        data-summary="Executive summary with clear risks, controls, and time-to-breach indicators."
        data-bullets="Top risks|Control heatmap|Time-to-breach|Decisions needed">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M3 3h18v6H3zm0 8h8v10H3zm10 0h8v10h-8z"/></svg>
          </span>
          <h3>Board Risk Brief</h3>
        </div>
        <p class="r-copy">What leadership needs to know — on one page.</p>
        <div class="r-foot"><span class="r-price">from £1,250</span><button class="btn r-open">View details</button></div>
      </article>

      <article class="r-card"
        data-title="Litigation Evidence Readiness Check"
        data-price="from £850"
        data-time="3–6 days"
        data-summary="Are you ready to file? Gaps, redactions, hashes, and exportable pack."
        data-bullets="Gaps & fixes|Hash receipts|Redaction review|Export pack">
        <div class="r-top">
          <span class="r-ico">
            <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="#071018" d="M6 2h12v4H6zM4 8h16v14H4z"/></svg>
          </span>
          <h3>Evidence Readiness</h3>
        </div>
        <p class="r-copy">No surprises on deadline day.</p>
        <div class="r-foot"><span class="r-price">from £850</span><button class="btn r-open">View details</button></div>
      </article>

    </div>
  </div>
</section>
HTML

  awk -v RS= -v ORS= '
    /<main[^>]*>/ && !done { done=1; print; system("cat .rbis_grid_block.tmp"); next } 1
  ' "$f_html" > .tmp && mv .tmp "$f_html"
  rm -f .rbis_grid_block.tmp
fi

# --- Canonical (keep /reports canonical) ---
if ! grep -q '<link rel="canonical"' "$f_html"; then
  sed -i 's#<link rel="stylesheet" href="/assets/rbis.css">#<link rel="stylesheet" href="/assets/rbis.css">\n<link rel="canonical" href="https://www.rbisintelligence.com/reports.html">#' "$f_html"
fi

# --- JSON-LD ItemList (replace existing ItemList or add fresh) ---
cat > .rbis_itemlist.json <<'JSON'
{
  "@context":"https://schema.org",
  "@type":"ItemList",
  "name":"RBIS Professional Reports",
  "itemListElement":[
    {"@type":"ListItem","position":1,"item":{"@type":"Product","name":"Housing Disrepair Claim Review","offers":{"@type":"Offer","price":"495","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":2,"item":{"@type":"Product","name":"Timeline Consistency Report","offers":{"@type":"Offer","price":"395","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":3,"item":{"@type":"Product","name":"Communications Credibility Analysis","offers":{"@type":"Offer","price":"595","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":4,"item":{"@type":"Product","name":"Forensic Document & Image Audit","offers":{"@type":"Offer","price":"650","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":5,"item":{"@type":"Product","name":"Fraud Pattern & Risk Indicators","offers":{"@type":"Offer","price":"795","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":6,"item":{"@type":"Product","name":"Contractor Claim & Invoice Audit","offers":{"@type":"Offer","price":"795","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":7,"item":{"@type":"Product","name":"Ombudsman / Board Pack QA","offers":{"@type":"Offer","price":"495","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":8,"item":{"@type":"Product","name":"Workplace Dispute Behavioural Brief","offers":{"@type":"Offer","price":"695","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":9,"item":{"@type":"Product","name":"Voice & Tone Analysis (Calls)","offers":{"@type":"Offer","price":"550","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":10,"item":{"@type":"Product","name":"Incident After-Action Review","offers":{"@type":"Offer","price":"995","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":11,"item":{"@type":"Product","name":"Board Risk & Controls Brief","offers":{"@type":"Offer","price":"1250","priceCurrency":"GBP"}}},
    {"@type":"ListItem","position":12,"item":{"@type":"Product","name":"Litigation Evidence Readiness Check","offers":{"@type":"Offer","price":"850","priceCurrency":"GBP"}}}
  ]
}
JSON

if grep -q '"@type":"ItemList"' "$f_html"; then
  # remove existing ItemList block
  awk -v RS= -v ORS= '
    BEGIN{ skip=0 }
    /<script[^>]*application\/ld\+json[^>]*>/ {
      if ($0 ~ /"@type"\s*:\s*"ItemList"/) { skip=1; next }
    }
    /<\/script>/ { if (skip) { skip=0; next } }
    { if (!skip) print }
  ' "$f_html" > .tmp && mv .tmp "$f_html"
fi
# append fresh ItemList into <head>
awk -v RS= -v ORS= '
  /<\/head>/ && !done {
    done=1
    print "<script type=\"application/ld+json\">"; system("cat .rbis_itemlist.json"); print "</script>"
    print
    next
  }1
' "$f_html" > .tmp && mv .tmp "$f_html"
rm -f .rbis_itemlist.json

echo "✓ Reports polished ($STAMP)"
