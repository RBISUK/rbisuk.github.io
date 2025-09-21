#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
FILE="reports.html"; [[ -f "$FILE" ]] || exit 0
DATA="$(awk '/<script id="report-data"/,/<\/script>/' "$FILE" | sed '1d;$d')"
[[ -z "$DATA" ]] && { echo "no report-data"; exit 0; }

python3 - "$FILE" <<'PY'
import sys, json, re, pathlib
fp = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
m = re.search(r'<script id="report-data"[^>]*>(.*?)</script>', fp, re.S)
data = json.loads(m.group(1)) if m else []
itemlist = {"@context":"https://schema.org","@type":"ItemList","name":"RBIS Reports","itemListElement":[]}
articles=[]
for i, r in enumerate(data, start=1):
    itemlist["itemListElement"].append({"@type":"ListItem","position":i,"url":f"https://www.rbisintelligence.com/reports.html#{r.get('id','')}"})
    articles.append({
        "@context":"https://schema.org","@type":"Article",
        "headline": r.get("title",""),
        "about": r.get("type",""),
        "articleSection": r.get("industry",""),
        "dateModified": r.get("updated",""),
        "keywords": ", ".join(r.get("tags",[])),
        "description": r.get("summary",""),
        "url": f"https://www.rbisintelligence.com/reports.html#{r.get('id','')}"
    })
schema = "\n".join([
    '<script type="application/ld+json">'+json.dumps(itemlist,ensure_ascii=False)+'</script>',
    *['<script type="application/ld+json">'+json.dumps(a,ensure_ascii=False)+'</script>' for a in articles]
])
out = re.sub(r'<script id="report-ld"[^>]*>.*?</script>', '<script id="report-ld" type="application/ld+json">'+json.dumps(itemlist,ensure_ascii=False)+'</script>', fp, flags=re.S)
# append per-article blocks just before </body>
out = re.sub(r'</body>', schema+'\n</body>', out, count=1, flags=re.S)
pathlib.Path(sys.argv[1]).write_text(out, encoding="utf-8")
print("✅ reports schema refreshed")
PY
