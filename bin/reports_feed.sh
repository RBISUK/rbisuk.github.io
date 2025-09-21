#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
FILE="reports.html"; [[ -f "$FILE" ]] || { echo "no reports.html"; exit 0; }
DATA="$(awk '/<script id="report-data"/,/<\/script>/' "$FILE" | sed '1d;$d')"
[[ -z "${DATA:-}" ]] && { echo "no report-data"; exit 0; }

python3 - <<'PY'
import sys, json, datetime, html, re, pathlib
ORIGIN = sys.argv[1]
fp = pathlib.Path("reports.html").read_text(encoding="utf-8")
m = re.search(r'<script id="report-data"[^>]*>(.*?)</script>', fp, re.S)
data = json.loads(m.group(1)) if m else []
updated = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
items=[]
for r in data:
    rid = r.get('id','')
    u = f"{ORIGIN}/reports.html#{rid}"
    t = html.escape(r.get("title","RBIS Report"))
    s = html.escape(r.get("summary",""))
    items.append(f"<entry><title>{t}</title><link href=\"{u}\"/><id>{u}</id><updated>{updated}</updated><summary>{s}</summary></entry>")
feed = f"""<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>RBIS Reports</title>
  <id>{ORIGIN}/reports.xml</id>
  <link href="{ORIGIN}/reports.xml" rel="self"/>
  <updated>{updated}</updated>
  {''.join(items)}
</feed>"""
pathlib.Path("reports.xml").write_text(feed, encoding="utf-8")
print("✅ reports.xml built")
PY "$ORIGIN"
