#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ ERR at line $LINENO: $BASH_COMMAND" >&2' ERR

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p _backups

# --- SVG logo into nav brand (once per page) ---
SVG='<svg class="mark" viewBox="0 0 120 120" aria-hidden="true"><defs><linearGradient id="lg" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="#7cf"/><stop offset="55%" stop-color="#92ff72"/><stop offset="100%" stop-color="#88aaff"/></linearGradient></defs><g fill="url(#lg)"><path d="M60 6 96 24 114 60 96 96 60 114 24 96 6 60 24 24Z" opacity=".22"/><path d="M60 16 88 30 104 60 88 90 60 104 32 90 16 60 32 30Z" opacity=".35"/><path d="M60 26 80 36 94 60 80 84 60 94 40 84 26 60 40 36Z"/></g></svg><span>RBIS</span>'
for f in index.html products.html offerings.html reports.html solutions.html trust.html about.html websites.html contact.html dashboard.html; do
  [ -f "$f" ] || continue
  cp -f "$f" "_backups/$f.$STAMP" || true
  if grep -q '<a[^>]*class="[^"]*brand' "$f" && ! grep -q 'class="mark"' "$f"; then
    perl -0777 -pe 's#(<a[^>]*class="[^"]*brand[^"]*"[^>]*>)(.*?)(</a>)#$1'"$SVG"'$3#s' -i "$f"
    echo "• logo injected: $f"
  fi
done

# --- minimal CSS support for the logo ---
mkdir -p assets
touch assets/rbis.css
cp -f assets/rbis.css "_backups/rbis.css.$STAMP" || true
grep -q '\.brand \.mark' assets/rbis.css || cat >> assets/rbis.css <<'CSS'

/* RBIS brand lockup */
.brand{display:flex;gap:10px;align-items:center;color:var(--ink);font-weight:700;letter-spacing:.2px}
.brand .mark{width:28px;height:28px;display:inline-block;filter:drop-shadow(0 8px 24px rgba(120,160,255,.25))}
.brand span{font-size:18px}
CSS

# --- Canonical + full ItemList JSON-LD on reports.html ---
if [ -f reports.html ]; then
  cp -f reports.html "_backups/reports.html.$STAMP" || true
  grep -q '<link rel="canonical"' reports.html || \
    sed -i 's#<link rel="stylesheet" href="/assets/rbis.css">#<link rel="stylesheet" href="/assets/rbis.css">\n<link rel="canonical" href="https://www.rbisintelligence.com/reports.html">#' reports.html

  # Remove any previous ItemList block we added
  awk 'BEGIN{del=0}
       /<script type="application\/ld\+json">/{buf=""; del=1}
       { if(!del) print; if(del) buf=buf $0 "\n" }
       /<\/script>/{ if(del && buf ~ /"@type":"ItemList"/){del=0; next} del=0 }' reports.html > .tmp && mv .tmp reports.html

  # Fresh ItemList (31 services w/ prices)
  cat >> reports.html <<'JSONLD'
<script type="application/ld+json">
{
  "@context":"https://schema.org",
  "@type":"ItemList",
  "itemListElement":[
    { "@type":"ListItem","position":1,"item":{"@type":"Service","name":"Housing Disrepair Claim Review","url":"https://www.rbisintelligence.com/reports.html#housing-disrepair-claim-review","offers":{"@type":"Offer","priceCurrency":"GBP","price":"495"}}},
    { "@type":"ListItem","position":2,"item":{"@type":"Service","name":"Damp & Mould Causation Analysis","url":"https://www.rbisintelligence.com/reports.html#damp-mould-causation-analysis","offers":{"@type":"Offer","priceCurrency":"GBP","price":"595"}}},
    { "@type":"ListItem","position":3,"item":{"@type":"Service","name":"Repair Chronology & SLA Breach Audit","url":"https://www.rbisintelligence.com/reports.html#repair-chronology-sla-breach-audit","offers":{"@type":"Offer","priceCurrency":"GBP","price":"495"}}},
    { "@type":"ListItem","position":4,"item":{"@type":"Service","name":"Tenant Tone & Credibility Assessment","url":"https://www.rbisintelligence.com/reports.html#tenant-tone-credibility-assessment","offers":{"@type":"Offer","priceCurrency":"GBP","price":"395"}}},
    { "@type":"ListItem","position":5,"item":{"@type":"Service","name":"Evidence Completeness & Gap Analysis","url":"https://www.rbisintelligence.com/reports.html#evidence-completeness-gap-analysis","offers":{"@type":"Offer","priceCurrency":"GBP","price":"375"}}},
    { "@type":"ListItem","position":6,"item":{"@type":"Service","name":"Contractor Performance & Missed Appointments Audit","url":"https://www.rbisintelligence.com/reports.html#contractor-performance-missed-appointments","offers":{"@type":"Offer","priceCurrency":"GBP","price":"425"}}},
    { "@type":"ListItem","position":7,"item":{"@type":"Service","name":"Vulnerability & Risk Scoring Report","url":"https://www.rbisintelligence.com/reports.html#vulnerability-risk-scoring","offers":{"@type":"Offer","priceCurrency":"GBP","price":"450"}}},
    { "@type":"ListItem","position":8,"item":{"@type":"Service","name":"Disrepair Risk Heatmap (Estate/Block)","url":"https://www.rbisintelligence.com/reports.html#disrepair-risk-heatmap","offers":{"@type":"Offer","priceCurrency":"GBP","price":"650"}}},
    { "@type":"ListItem","position":9,"item":{"@type":"Service","name":"Board Pack: Disrepair KPIs & Trends","url":"https://www.rbisintelligence.com/reports.html#board-pack-kpis-trends","offers":{"@type":"Offer","priceCurrency":"GBP","price":"1200"}}},
    { "@type":"ListItem","position":10,"item":{"@type":"Service","name":"Ombudsman Case Readiness Pack","url":"https://www.rbisintelligence.com/reports.html#ombudsman-case-readiness","offers":{"@type":"Offer","priceCurrency":"GBP","price":"850"}}},
    { "@type":"ListItem","position":11,"item":{"@type":"Service","name":"Data Minimisation & Privacy Posture Review","url":"https://www.rbisintelligence.com/reports.html#data-minimisation-privacy-posture","offers":{"@type":"Offer","priceCurrency":"GBP","price":"600"}}},
    { "@type":"ListItem","position":12,"item":{"@type":"Service","name":"GDPR DSAR Workflow Readiness Audit","url":"https://www.rbisintelligence.com/reports.html#gdpr-dsar-workflow-readiness","offers":{"@type":"Offer","priceCurrency":"GBP","price":"550"}}},
    { "@type":"ListItem","position":13,"item":{"@type":"Service","name":"Consent & PECR Compliance Review","url":"https://www.rbisintelligence.com/reports.html#consent-pecr-compliance","offers":{"@type":"Offer","priceCurrency":"GBP","price":"500"}}},
    { "@type":"ListItem","position":14,"item":{"@type":"Service","name":"Retention Schedule Fitness Check","url":"https://www.rbisintelligence.com/reports.html#retention-schedule-fitness","offers":{"@type":"Offer","priceCurrency":"GBP","price":"450"}}},
    { "@type":"ListItem","position":15,"item":{"@type":"Service","name":"Web Accessibility WCAG 2.2 AA Snapshot","url":"https://www.rbisintelligence.com/reports.html#web-accessibility-wcag-22","offers":{"@type":"Offer","priceCurrency":"GBP","price":"400"}}},
    { "@type":"ListItem","position":16,"item":{"@type":"Service","name":"Core Web Vitals Performance Snapshot","url":"https://www.rbisintelligence.com/reports.html#core-web-vitals-snapshot","offers":{"@type":"Offer","priceCurrency":"GBP","price":"350"}}},
    { "@type":"ListItem","position":17,"item":{"@type":"Service","name":"Search & Entity Coverage Audit","url":"https://www.rbisintelligence.com/reports.html#search-entity-coverage","offers":{"@type":"Offer","priceCurrency":"GBP","price":"600"}}},
    { "@type":"ListItem","position":18,"item":{"@type":"Service","name":"Reputation & Risk Monitoring Baseline","url":"https://www.rbisintelligence.com/reports.html#reputation-risk-baseline","offers":{"@type":"Offer","priceCurrency":"GBP","price":"500"}}},
    { "@type":"ListItem","position":19,"item":{"@type":"Service","name":"Behavioural Pattern Analysis (Comms & Actions)","url":"https://www.rbisintelligence.com/reports.html#behavioural-pattern-analysis","offers":{"@type":"Offer","priceCurrency":"GBP","price":"700"}}},
    { "@type":"ListItem","position":20,"item":{"@type":"Service","name":"Image & Document Authenticity Screening","url":"https://www.rbisintelligence.com/reports.html#image-document-authenticity","offers":{"@type":"Offer","priceCurrency":"GBP","price":"650"}}},
    { "@type":"ListItem","position":21,"item":{"@type":"Service","name":"Audio Forensics Screening (Voice/Tone)","url":"https://www.rbisintelligence.com/reports.html#audio-forensics-screening","offers":{"@type":"Offer","priceCurrency":"GBP","price":"700"}}},
    { "@type":"ListItem","position":22,"item":{"@type":"Service","name":"Timeline Reconstruction & Consistency Check","url":"https://www.rbisintelligence.com/reports.html#timeline-reconstruction","offers":{"@type":"Offer","priceCurrency":"GBP","price":"550"}}},
    { "@type":"ListItem","position":23,"item":{"@type":"Service","name":"Financial Irregularity Signal Scan","url":"https://www.rbisintelligence.com/reports.html#financial-irregularity-scan","offers":{"@type":"Offer","priceCurrency":"GBP","price":"750"}}},
    { "@type":"ListItem","position":24,"item":{"@type":"Service","name":"Workplace Dispute Credibility Assessment","url":"https://www.rbisintelligence.com/reports.html#workplace-dispute-credibility","offers":{"@type":"Offer","priceCurrency":"GBP","price":"600"}}},
    { "@type":"ListItem","position":25,"item":{"@type":"Service","name":"HR Investigation Evidence Pack","url":"https://www.rbisintelligence.com/reports.html#hr-investigation-evidence-pack","offers":{"@type":"Offer","priceCurrency":"GBP","price":"900"}}},
    { "@type":"ListItem","position":26,"item":{"@type":"Service","name":"Litigation Readiness Assessment","url":"https://www.rbisintelligence.com/reports.html#litigation-readiness","offers":{"@type":"Offer","priceCurrency":"GBP","price":"1100"}}},
    { "@type":"ListItem","position":27,"item":{"@type":"Service","name":"Promise & Commitment Compliance Audit (PACT)","url":"https://www.rbisintelligence.com/reports.html#promise-commitment-audit","offers":{"@type":"Offer","priceCurrency":"GBP","price":"500"}}},
    { "@type":"ListItem","position":28,"item":{"@type":"Service","name":"Automation Runbook Proof Coverage Audit (OmniAssist)","url":"https://www.rbisintelligence.com/reports.html#automation-proof-coverage","offers":{"@type":"Offer","priceCurrency":"GBP","price":"550"}}},
    { "@type":"ListItem","position":29,"item":{"@type":"Service","name":"CRM Lawful Basis & Retention Audit (NextusOne)","url":"https://www.rbisintelligence.com/reports.html#crm-lawful-basis-retention","offers":{"@type":"Offer","priceCurrency":"GBP","price":"600"}}},
    { "@type":"ListItem","position":30,"item":{"@type":"Service","name":"Intelligence Dashboard KPI Design Workshop","url":"https://www.rbisintelligence.com/reports.html#dashboard-kpi-design","offers":{"@type":"Offer","priceCurrency":"GBP","price":"1500"}}},
    { "@type":"ListItem","position":31,"item":{"@type":"Service","name":"Executive Rapid Risk Assessment (48h)","url":"https://www.rbisintelligence.com/reports.html#executive-rapid-risk","offers":{"@type":"Offer","priceCurrency":"GBP","price":"1800"}}}
  ]
}
</script>
JSONLD
fi

# --- Organization JSON-LD on index (once) ---
if [ -f index.html ] && ! grep -q '"@type":"Organization"' index.html; then
  cp -f index.html "_backups/index.html.$STAMP" || true
  awk -v RS= -v ORS= '
    /<\/head>/{
      sub(/<\/head>/,
      "<script type=\"application/ld+json\">{\"@context\":\"https://schema.org\",\"@type\":\"Organization\",\"name\":\"RBIS\",\"url\":\"https://www.rbisintelligence.com\",\"logo\":{\"@type\":\"ImageObject\",\"url\":\"https://www.rbisintelligence.com/assets/logo.svg\"},\"sameAs\":[\"https://www.linkedin.com/company/rbis-intelligence\"]}</script>\n</head>")
    }1' index.html > .tmp && mv .tmp index.html
  echo "• org JSON-LD added to index.html"
fi

# Commit & push if changed
git add -A
if git diff --cached --quiet; then
  echo "ℹ️ No changes to commit"
else
  git commit -m "ux+seo: nav SVG logo + reports ItemList JSON-LD ($STAMP)"
  git push
fi
