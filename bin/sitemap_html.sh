#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
python3 - <<'PY' > sitemap.html
import xml.etree.ElementTree as ET, html
NS = {'sm':'http://www.sitemaps.org/schemas/sitemap/0.9'}
urls=[]
try:
    tree=ET.parse('sitemap.xml')
    for u in tree.findall('sm:url/sm:loc', NS):
        urls.append(u.text or '')
except Exception:
    pass
print('<!doctype html><meta charset="utf-8"><title>Sitemap • RBIS</title><h1>Site map</h1><ul>')
for u in urls:
    e=html.escape(u)
    print(f'<li><a href="{e}">{e}</a></li>')
print('</ul>')
PY
echo "✅ sitemap.html built"
