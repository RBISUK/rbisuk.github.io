#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"; ORIGIN="${ORIGIN%/}"

# sitemap.xml
python3 - "$ORIGIN" > sitemap.xml <<'PY'
import sys, subprocess
from xml.sax.saxutils import escape
origin = sys.argv[1].rstrip('/')
files = subprocess.run(['git','ls-files','*.html'], capture_output=True, text=True).stdout.splitlines()
urls = []
if 'index.html' in files:
    urls.append(origin + '/')
for f in files:
    urls.append(origin + '/' + f)
print('<?xml version="1.0" encoding="UTF-8"?>')
print('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
for u in sorted(set(urls)):
    print('  <url><loc>%s</loc></url>' % escape(u))
print('</urlset>')
PY
echo "✅ sitemap.xml rebuilt"

# sitemap.html (human-friendly)
python3 - > sitemap.html <<'PY'
import xml.etree.ElementTree as ET, html
ns={'sm':'http://www.sitemaps.org/schemas/sitemap/0.9'}
tree = ET.parse('sitemap.xml')
locs = [e.text for e in tree.findall('.//sm:loc', ns)]
print('<!doctype html><meta charset="utf-8"><title>Sitemap • RBIS</title>')
print('<meta name="viewport" content="width=device-width,initial-scale=1">')
print('<h1>Sitemap</h1><ul>')
for u in locs:
    s = html.escape(u)
    print(f'<li><a href="{s}">{s}</a></li>')
print('</ul>')
PY
echo "✅ sitemap.html built"

# sitemap index (points to main + reports feed)
cat > sitemap_index.xml <<XML
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap><loc>${ORIGIN}/sitemap.xml</loc></sitemap>
  <sitemap><loc>${ORIGIN}/reports.xml</loc></sitemap>
</sitemapindex>
XML
echo "✅ sitemap_index.xml built"
