#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"; ORIGIN="${ORIGIN%/}"

python3 - "$ORIGIN" > sitemap.xml <<'PY'
import sys, subprocess, html
origin = sys.argv[1].rstrip('/')
files = subprocess.run(['git','ls-files','*.html'], capture_output=True, text=True).stdout.split()
urls = []
if 'index.html' in files:
    urls.append(origin + '/')
for f in files:
    # encode only spaces and unsafe chars—keep slashes
    u = origin + '/' + f.replace(' ', '%20')
    urls.append(u)

print('<?xml version="1.0" encoding="UTF-8"?>')
print('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
for u in urls:
    print(f'  <url><loc>{html.escape(u)}</loc></url>')
print('</urlset>')
PY

echo "✅ sitemap.xml rebuilt"
