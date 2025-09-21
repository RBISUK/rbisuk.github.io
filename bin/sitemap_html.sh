#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
[[ -f sitemap.xml ]] || { echo "no sitemap.xml"; exit 0; }
python3 - <<'PY'
from pathlib import Path
import re, html
txt = Path("sitemap.xml").read_text(encoding="utf-8", errors="ignore")
locs = re.findall(r'<loc>\s*(.*?)\s*</loc>', txt, flags=re.I|re.S)
items = '\n'.join(f'<li><a href="{html.escape(u)}">{html.escape(u)}</a></li>' for u in locs)
page = f"""<!doctype html><meta charset="utf-8"><title>Sitemap • RBIS</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<link rel="stylesheet" href="/assets/rbis.css">
<main class="container"><h1>Sitemap</h1><ul>{items}</ul></main>"""
Path("sitemap.html").write_text(page, encoding="utf-8")
print("✅ sitemap.html built")
PY
