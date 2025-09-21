#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p reports
if [[ -f reports.xml ]]; then
python3 - <<'PY' > reports/index.html
import xml.etree.ElementTree as ET, html
from datetime import datetime
tree=ET.parse('reports.xml'); root=tree.getroot()
entries=[]
for e in root.findall('{http://www.w3.org/2005/Atom}entry'):
    t=e.find('{http://www.w3.org/2005/Atom}title')
    l=e.find('{http://www.w3.org/2005/Atom}link')
    s=e.find('{http://www.w3.org/2005/Atom}summary')
    u=l.get('href') if l is not None else '#'
    entries.append((t.text if t is not None else 'Report', u, (s.text or '') if s is not None else ''))
entries=entries[:100]
print("""<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Reports • RBIS Intelligence</title><link rel="stylesheet" href="/assets/nav-fix.css">
<body><a class="skip-to-content" href="#main">Skip to content</a>
<main id="main" class="container" style="max-width:1100px;margin:2rem auto;padding:0 1rem">
<h1 style="font-size:2rem;margin:.5rem 0 1.25rem">Professional Reports</h1>
<p style="color:#4b5563;margin-bottom:1rem">Selected outputs, exports, and heatmaps.</p>
<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:1rem">""")
for t,u,s in entries:
    print(f"""<a class="block rounded-xl" href="{html.escape(u)}" style="border:1px solid #e5e7eb;padding:1rem;text-decoration:none;color:#111">
<div class="chip-esign" style="background:#F3F4F6;color:#374151;border-color:#E5E7EB">Report</div>
<h2 style="font-size:1.05rem;margin:.6rem 0 .25rem">{html.escape(t)}</h2>
<p style="color:#6b7280;margin:0">{html.escape(s[:140])}</p></a>""")
print("</div></main>")
PY
echo "✅ reports/index.html built from Atom feed"
else
  echo "ℹ️ reports.xml not found; nothing to build"
fi
