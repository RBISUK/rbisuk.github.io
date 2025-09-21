#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"; ORIGIN="${ORIGIN%/}"

python3 - "$ORIGIN" > reports.xml <<'PY'
import os, datetime, html, sys
origin = sys.argv[1].rstrip('/')
now = datetime.datetime.now(datetime.timezone.utc).isoformat()

items = []
base = 'reports'
if os.path.isdir(base):
    for name in sorted(os.listdir(base)):
        if name.endswith(('.csv', '.txt', '.html')):
            u = f"{origin}/{base}/{name}"
            t = f"Report: {name}"
            s = f"Latest {name}"
            items.append(f"<entry><title>{html.escape(t)}</title>"
                         f"<link href=\"{html.escape(u)}\"/>"
                         f"<id>{html.escape(u)}</id>"
                         f"<updated>{now}</updated>"
                         f"<summary>{html.escape(s)}</summary></entry>")

print('<?xml version="1.0" encoding="utf-8"?>')
print('<feed xmlns="http://www.w3.org/2005/Atom">')
print('<title>RBIS Reports</title>')
print('<id>' + origin + '/reports.xml</id>')
print('<updated>' + now + '</updated>')
for e in items: print(e)
print('</feed>')
PY

# Inject <link rel="alternate"> into reports.html if present (idempotent)
if git ls-files --error-unmatch reports.html >/dev/null 2>&1; then
  perl -0777 -pe '
    if (!/<link\s+rel="alternate"\s+type="application\/atom\+xml"/i) {
      s#</head>#<link rel="alternate" type="application/atom+xml" href="/reports.xml">\n</head>#i
    } $_;
  ' -i reports.html
fi

echo "✅ reports.xml built and <link rel=\"alternate\"> ensured"
