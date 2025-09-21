#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
python3 - <<'PY'
import os, sys, datetime, subprocess, urllib.parse
ORIGIN = os.environ.get("SITE_ORIGIN","https://www.rbisintelligence.com").rstrip("/")
now = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
listed = subprocess.run(["git","ls-files","*.html"], capture_output=True, text=True).stdout.splitlines()
urls = []
if "index.html" in listed:
    urls.append(ORIGIN + "/")
for f in listed:
    loc = "/" + f
    # keep reserved characters that are valid in URLs; escape others safely
    url = ORIGIN + urllib.parse.quote(loc, safe="/:#?%[]@!$&'()*+,;=")
    urls.append(url)
print('<?xml version="1.0" encoding="UTF-8"?>')
print('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
for u in urls:
    print(f'  <url><loc>{u}</loc><lastmod>{now}</lastmod></url>')
print('</urlset>')
PY > sitemap.xml
echo "✅ sitemap.xml rebuilt"
