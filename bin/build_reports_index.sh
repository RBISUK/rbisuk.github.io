#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p reports
mapfile -t PAGES < <(git ls-files 'reports/*.html' | grep -vE '/index\.html$|/a11y/|/feed|/atom|/sitemap' || true)
cards=""
for f in "${PAGES[@]}"; do
  href="/$f"
  title="$(rg -No '(?<=<title>)(.*?)(?=</title>)' "$f" 2>/dev/null | head -n1 || true)"
  [[ -z "$title" ]] && title="$(basename "$f" .html | tr '-' ' ' | sed 's/.*/\u&/')"
  summary="$(rg -No '(?<=<meta name="description" content=")([^"]+)' "$f" 2>/dev/null | head -n1 || true)"
  cards+="<a class=\"block rounded-xl border border-gray-200 p-4 hover:shadow-sm\" href=\"$href\">
            <div class=\"chip\" style=\"background:#F3F4F6;color:#374151;display:inline-flex;padding:.25rem .5rem;border-radius:999px;font-size:.8rem;margin-bottom:.5rem\">Report</div>
            <h3 class=\"text-lg font-semibold\" style=\"margin:0 0 .25rem\">${title}</h3>
            <p class=\"text-sm\" style=\"color:#4B5563;margin:0\">${summary}</p>
          </a>
"
done
cat > reports/index.html <<HTML
<!doctype html><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<link rel="stylesheet" href="/assets/nav-fix.css">
<link rel="stylesheet" href="/assets/site.min.css">
<title>Reports • RBIS</title>
<header class="border-b" style="border-bottom:1px solid #e5e7eb">
  <div style="max-width:80rem;margin:0 auto;padding:1rem;display:flex;align-items:center;justify-content:space-between">
    <a href="/" style="font-weight:600">RBIS</a>
    <details class="rbis-nav">
      <summary class="rbis-burger"><span class="rbis-sr">Menu</span></summary>
      <div class="rbis-drawer">
        <nav class="rbis-nav-row">
          <a href="/products.html">Products & Services</a>
          <a href="/reports/" aria-current="page">Reports</a>
          <a href="/solutions.html">Solutions</a>
          <a href="/trust.html">Trust Centre</a>
          <a href="/about.html">About</a>
          <a href="/contact.html">Contact us</a>
        </nav>
      </div>
    </details>
  </div>
</header>
<main id="main" style="max-width:80rem;margin:0 auto;padding:1rem">
  <h1 style="font-size:clamp(1.75rem,3vw,2.5rem);margin:.5rem 0">Reports</h1>
  <p style="color:#4B5563;margin:.25rem 0 1rem">Risk heatmaps, board exports, audit packs.</p>
  <div class="grid" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:1rem">
    ${cards:-<div style="color:#6B7280">No reports found yet.</div>}
  </div>
</main>
<footer style="margin-top:3rem;border-top:1px solid #e5e7eb">
  <div style="max-width:80rem;margin:0 auto;padding:1rem;color:#6B7280;font-size:.875rem">© RBIS Intelligence</div>
</footer>
HTML
echo "✅ reports/index.html built (${#PAGES[@]} items)"
