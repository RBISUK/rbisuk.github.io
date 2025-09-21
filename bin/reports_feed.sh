#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"; ORIGIN="${ORIGIN%/}"
[[ -f reports.html ]] || { echo "ℹ️ no reports.html, skipping feed"; exit 0; }
python3 - "$ORIGIN" > reports.xml <<'PY'
import sys, re, json, html, datetime
origin = sys.argv[1].rstrip('/')
fp = open('reports.html', encoding='utf-8').read()
m = re.search(r'<script[^>]*id="report-data"[^>]*>(.*?)</script>', fp, re.S|re.I)
if not m:
    print('<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom"></feed>')
    raise SystemExit
try:
    data = json.loads(m.group(1))
except Exception:
    data = []
updated = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
out = []
out.append('<?xml version="1.0" encoding="UTF-8"?>')
out.append('<feed xmlns="http://www.w3.org/2005/Atom">')
out.append(f'<title>RBIS Reports</title>')
out.append(f'<id>{html.escape(origin)}/reports.xml</id>')
out.append(f'<updated>{updated}</updated>')
for r in (data if isinstance(data, list) else []):
    rid = r.get('id') or r.get('slug') or ''
    url = f"{origin}/reports.html#{rid}" if rid else f"{origin}/reports.html"
    t = html.escape(r.get('title','RBIS Report'))
    s = html.escape(r.get('summary',''))
    out.append('<entry>')
    out.append(f'  <title>{t}</title>')
    out.append(f'  <link href="{html.escape(url)}" />')
    out.append(f'  <id>{html.escape(url)}</id>')
    out.append(f'  <updated>{updated}</updated>')
    if s: out.append(f'  <summary>{s}</summary>')
    out.append('</entry>')
out.append('</feed>')
print("\n".join(out))
PY
echo "✅ reports.xml built"

# add <link rel="alternate" ...> once
if ! rg -q 'rel="alternate".*application/atom\+xml' reports.html; then
  perl -0777 -pe 's#</head>#<link rel="alternate" type="application/atom+xml" title="RBIS Reports" href="/reports.xml">\n</head>#i' -i reports.html
  echo "🔗 <link rel=\"alternate\" type=\"application/atom+xml\"> injected into reports.html"
fi
