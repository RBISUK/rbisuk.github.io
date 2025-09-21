#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
echo "�� RBIS coolify+ starting…"

ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
backup(){ [[ -f "$1" ]] && cp -p "$1" "$1.bak.$STAMP" || true; }

# ---------- Install tools (best-effort) ----------
pm=""
if command -v apt-get >/dev/null; then pm="apt"
elif command -v brew >/dev/null; then pm="brew"
elif command -v choco >/dev/null; then pm="choco"
fi
install(){
  case "$pm" in
    apt)
      sudo apt-get update -y
      sudo apt-get install -y imagemagick pngquant optipng jpegoptim webp gifsicle \
        exiftool jq xmlstarlet parallel tidy curl ripgrep nodejs npm python3 python3-pip >/dev/null
      ;;
    brew)
      brew install imagemagick pngquant optipng jpegoptim webp gifsicle \
        exiftool jq xmlstarlet gnu-parallel tidy-html5 curl ripgrep node python >/dev/null
      ;;
    choco)
      choco install -y imagemagick pngquant optipng jpegoptim webp gifsicle \
        exiftool jq xmlstarlet curl ripgrep nodejs python >/dev/null
      ;;
    *) echo "ℹ️ No supported package manager; skipping system installs.";;
  esac
}
install || true

# Node dev CLIs (allow npx fallback if package.json missing)
if command -v npm >/dev/null; then
  if [[ -f package.json ]]; then
    npm pkg set private=true >/dev/null 2>&1 || true
    npm add -D svgo html-minifier-terser clean-css-cli uglify-js \
      linkinator pa11y-ci @lhci/cli workbox-cli >/dev/null 2>&1 || true
  fi
fi

# ---------- Fixes to existing scripts ----------
mkdir -p assets/og assets/icons

# Harden breadcrumbs: avoid $1 unbound + safer caps
cat > bin/schema_breadcrumbs.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
cap(){ local s="${1:-}"; printf '%s' "$s" | awk -F'-' '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } print}' | sed 's/&/ & /g;s/  */ /g'; }
title_for(){ sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$1" | head -n1 | sed 's/ •.*$//' ; }
for f in $(git ls-files '*.html' | sort); do
  [[ "$f" == "index.html" ]] && continue
  url="$ORIGIN/${f}"
  path="${f%/*}"
  pos=1; crumbs=()
  crumbs+=( "{\"@type\":\"ListItem\",\"position\":$((pos++)),\"name\":\"Home\",\"item\":\"$ORIGIN/\"}" )
  if [[ "$path" != "$f" && "$path" != "." ]]; then
    IFS='/' read -r -a segs <<<"$path"; build=""
    for s in "${segs[@]}"; do
      build="${build:+$build/}$s"
      name="$(cap "${s//_/ }")"
      crumbs+=( "{\"@type\":\"ListItem\",\"position\":$((pos++)),\"name\":\"$name\",\"item\":\"$ORIGIN/$build/\"}" )
    done
  fi
  leaf="$(title_for "$f")"; [[ -z "$leaf" ]] && leaf="$(cap "$(basename "$f" .html | sed 's/-/ /g')")"
  crumbs+=( "{\"@type\":\"ListItem\",\"position\":$((pos++)),\"name\":\"$leaf\",\"item\":\"$url\"}" )
  SCHEMA=$(cat <<JSON
<script id="rbis-bc" type="application/ld+json">
{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[${crumbs[*]}]}
</script>
JSON
)
  awk -v B="$SCHEMA" '
    BEGIN{done=0;skip=0}
    /<script id="rbis-bc"/{ if(!done){print B; done=1}; skip=1 }
    skip && /<\/script>/ { skip=0; next }
    /<\/head>/ && !done { print B; print; done=1; next }
    { if(!skip) print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ breadcrumbs -> $f"
done
EOS
chmod +x bin/schema_breadcrumbs.sh

# Reports Atom feed (fixed heredoc)
cat > bin/reports_feed.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
FILE="reports.html"; [[ -f "$FILE" ]] || { echo "no reports.html"; exit 0; }
DATA="$(awk '/<script id="report-data"/,/<\/script>/' "$FILE" | sed '1d;$d')" || true
[[ -z "${DATA:-}" ]] && { echo "no report-data"; exit 0; }
python3 - "$ORIGIN" <<'PY'
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
    items.append(f"<entry><title>{t}</title><link href=\\"{u}\\"/><id>{u}</id><updated>{updated}</updated><summary>{s}</summary></entry>")
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
PY
EOS
chmod +x bin/reports_feed.sh

# FAQ schema generator (from details/summary)
cat > bin/schema_faq.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  grep -q '<summary>' "$f" || continue
  mapfile -t blocks < <(perl -0777 -ne 'while (m|<details>(.*?)</details>|sg){print "$1\n---\n"}' "$f")
  declare -a items=(); count=0
  for b in "${blocks[@]}"; do
    q=$(sed -n 's/.*<summary>\(.*\)<\/summary>.*/\1/p' <<<"$b")
    a=$(sed -n 's/.*<\/summary>\(.*\)$/\1/p' <<<"$b" | sed 's/<[^>]*>//g' | tr -s " " " " | sed 's/^ *//;s/ *$//')
    [[ -z "$q" || -z "$a" ]] && continue
    count=$((count+1))
    items+=("{\"@type\":\"Question\",\"name\":\"$q\",\"acceptedAnswer\":{\"@type\":\"Answer\",\"text\":\"$a\"}}")
  done
  [[ $count -eq 0 ]] && continue
  SCHEMA=$(cat <<JSON
<script id="rbis-faq" type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[${items[*]}]}
</script>
JSON
)
  awk -v B="$SCHEMA" '
    BEGIN{done=0;skip=0}
    /<script id="rbis-faq"/{ if(!done){print B; done=1}; skip=1 }
    skip && /<\/script>/ { skip=0; next }
    /<\/head>/ && !done { print B; print; done=1; next }
    { if(!skip) print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ FAQ schema -> $f ($count Q/A)"
done
EOS
chmod +x bin/schema_faq.sh

# Lazy images (if not already)
cat > bin/lazy_images.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's/<img(?![^>]*\bloading=)([^>]*?)>/sprintf("<img loading=\"lazy\" decoding=\"async\"%s>",$1)/eig' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "✅ loading=\"lazy\" + decoding=\"async\" added to <img>"
EOS
chmod +x bin/lazy_images.sh

# Safe script deferring (skip inline/JSON-LD/module/async/defer)
cat > bin/defer_scripts.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's/<script(?![^>]*\b(type|async|defer)\b)([^>]*\bsrc=)([^>]*?)>/<script defer$2$3>/gi' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "✅ non-critical external <script> tagged with defer"
EOS
chmod +x bin/defer_scripts.sh

# SVGO optimization (non-destructive)
cat > bin/svgo_opt.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v npx >/dev/null || { echo "npx missing"; exit 0; }
find assets -type f -name '*.svg' | while read -r s; do
  cp -p "$s" "$s.bak.$(date -u +%Y%m%dT%H%M%SZ)"
  npx --yes svgo -q "$s" -o "$s"
  echo "🗜  svgo -> $s"
done
echo "✅ SVGs optimized"
EOS
chmod +x bin/svgo_opt.sh

# WebP copies (leave HTML unchanged)
cat > bin/image_webp.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v cwebp >/dev/null || { echo "ℹ️ cwebp not available; skipping."; exit 0; }
find assets -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | while read -r img; do
  out="${img%.*}.webp"
  if [[ ! -f "$out" || "$img" -nt "$out" ]]; then
    cwebp -quiet -q 82 "$img" -o "$out" && echo "🗜  webp -> $out"
  fi
done
echo "✅ WebP copies generated"
EOS
chmod +x bin/image_webp.sh

# Minify (conservative; backups kept)
cat > bin/minify_assets.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
min_html(){ npx --yes html-minifier-terser --collapse-whitespace --conservative-collapse --removeComments \
  --removeRedundantAttributes --removeScriptTypeAttributes --removeStyleLinkTypeAttributes --minify-css true --minify-js true; }
min_css(){ npx --yes cleancss -O2; }
min_js(){ npx --yes uglify-js -c -m; }
for f in $(git ls-files '*.html'); do cp -p "$f" "$f.bak.$(date -u +%Y%m%dT%H%M%SZ)"; min_html < "$f" > "$f.min" && mv "$f.min" "$f"; echo "🧼 html -> $f"; done
for f in $(git ls-files 'assets/**/*.css' 'assets/*.css' 2>/dev/null || true); do cp -p "$f" "$f.bak.$(date -u +%Y%m%dT%H%M%SZ)"; min_css < "$f" > "$f.min" && mv "$f.min" "$f"; echo "🧼 css -> $f"; done
for f in $(git ls-files 'assets/**/*.js' 'assets/*.js' 2>/dev/null || true);  do cp -p "$f" "$f.bak.$(date -u +%Y%m%dT%H%M%SZ)"; min_js  < "$f" > "$f.min" && mv "$f.min" "$f"; echo "🧼 js  -> $f"; done
echo "✅ minify complete"
EOS
chmod +x bin/minify_assets.sh

# Robots.txt (with sitemap)
cat > bin/robots_build.sh <<EOS
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=\$'\n\t'
cat > robots.txt <<ROBOTS
User-agent: *
Allow: /
Sitemap: ${ORIGIN}/sitemap.xml
ROBOTS
echo "✅ robots.txt built"
EOS
chmod +x bin/robots_build.sh

# Human HTML sitemap (from sitemap.xml if present)
cat > bin/sitemap_html.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
[[ -f sitemap.xml ]] || { echo "no sitemap.xml"; exit 0; }
python3 - <<'PY'
import xml.etree.ElementTree as ET, pathlib, html
tree = ET.parse('sitemap.xml')
urls = [u.find('{http://www.sitemaps.org/schemas/sitemap/0.9}loc').text for u in tree.findall('{http://www.sitemaps.org/schemas/sitemap/0.9}url')]
rows = '\n'.join(f'<li><a href="{html.escape(u)}">{html.escape(u)}</a></li>' for u in urls)
page = f"""<!doctype html><meta charset="utf-8"><title>Sitemap • RBIS</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<link rel="stylesheet" href="/assets/rbis.css">
<main class="container"><h1>Sitemap</h1><ul>{rows}</ul></main>"""
pathlib.Path("sitemap.html").write_text(page, encoding="utf-8")
print("✅ sitemap.html built")
PY
EOS
chmod +x bin/sitemap_html.sh

# Preload core CSS (safe add)
cat > bin/preload_css.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  grep -q 'rel="preload".*rbis.css' "$f" && continue
  awk '
    /<head[^>]*>/ && !added { print; print "<link rel=\"preload\" href=\"/assets/rbis.css\" as=\"style\">"; added=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ preload rbis.css -> $f"
done
EOS
chmod +x bin/preload_css.sh

# Optional Plausible analytics (inject only if RBIS_PLAUSIBLE_DOMAIN env var is set)
cat > bin/analytics_plausible.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
[[ -z "${RBIS_PLAUSIBLE_DOMAIN:-}" ]] && { echo "ℹ️ RBIS_PLAUSIBLE_DOMAIN not set; skipping analytics."; exit 0; }
for f in $(git ls-files '*.html'); do
  grep -q 'plausible.io/js' "$f" && continue
  awk -v D="$RBIS_PLAUSIBLE_DOMAIN" '
    /<\/head>/ && !done { print "<script defer data-domain=\"" D "\" src=\"https://plausible.io/js/script.js\"></script>"; print; done=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ plausible -> $f"
done
EOS
chmod +x bin/analytics_plausible.sh

# PWA ON/OFF (very conservative cache)
cat > bin/pwa_on.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
backup index.html
# offline fallback
cat > offline.html <<'HTML'
<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Offline • RBIS</title><link rel="stylesheet" href="/assets/rbis.css">
<main class="container"><h1>Offline</h1><p>You’re offline. Core pages and assets still work; refresh when back online.</p></main>
HTML
# service worker
cat > sw.js <<'JS'
const VERSION = 'rbis-v1';
const CORE = [
  '/', '/assets/rbis.css', '/assets/logo.svg', '/offline.html'
];
self.addEventListener('install', e=>{
  e.waitUntil(caches.open(VERSION).then(c=>c.addAll(CORE)));
});
self.addEventListener('activate', e=>{
  e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==VERSION).map(k=>caches.delete(k)))));
});
self.addEventListener('fetch', e=>{
  const u = new URL(e.request.url);
  if (u.origin === location.origin && (u.pathname.startsWith('/assets/') || u.pathname === '/' )) {
    e.respondWith(caches.match(e.request).then(r=> r || fetch(e.request).then(resp=>{
      const copy = resp.clone(); caches.open(VERSION).then(c=>c.put(e.request, copy)); return resp;
    })).catch(()=>caches.match('/offline.html')));
  }
});
JS
# register in pages
for f in $(git ls-files '*.html'); do
  grep -q 'navigator.serviceWorker' "$f" && continue
  awk '
    /<\/body>/ && !done {
      print "<script>if(\"serviceWorker\" in navigator){window.addEventListener(\"load\",()=>navigator.serviceWorker.register(\"/sw.js\").catch(()=>{}));}</script>";
      print; done=1; next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ PWA register -> $f"
done
echo "✅ PWA enabled (sw.js + offline.html + registration)"
EOS
chmod +x bin/pwa_on.sh

cat > bin/pwa_off.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
rm -f sw.js offline.html || true
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's/<script>if\\("serviceWorker".*?<\/script>//si' -i "$f" || true
done
echo "✅ PWA removed"
EOS
chmod +x bin/pwa_off.sh

# Accessibility + link checks
cat > bin/linkcheck.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
command -v npx >/dev/null || { echo "npx missing"; exit 0; }
npx --yes linkinator "$ORIGIN" --recurse --timeout 10000 --silent || true
EOS
chmod +x bin/linkcheck.sh

cat > bin/a11y_check.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v npx >/dev/null || { echo "npx missing"; exit 0; }
URLS=(
  "https://www.rbisintelligence.com/"
  "https://www.rbisintelligence.com/reports.html"
  "https://www.rbisintelligence.com/products.html"
  "https://www.rbisintelligence.com/trust/security/overview.html"
)
for u in "${URLS[@]}"; do echo "🔎 pa11y $u"; npx --yes pa11y-ci --sitemap "$u" --threshold 5 || true; done
EOS
chmod +x bin/a11y_check.sh

# HTML validation (tidy)
cat > bin/validate_html.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p reports
for f in $(git ls-files '*.html'); do
  tidy -qe "$f" > "reports/tidy-$(basename "$f").txt" 2>&1 || true
  echo "🧾 tidy -> reports/tidy-$(basename "$f").txt"
done
echo "✅ tidy reports generated (check ./reports)"
EOS
chmod +x bin/validate_html.sh

# Alt text audit
cat > bin/alt_audit.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
echo "Page|img src|has alt?" > reports/alt_audit.csv
for f in $(git ls-files '*.html'); do
  perl -0777 -ne 'while (m/<img([^>]+)>/gi){ $a=$1; ($src)=$a=~m/src="([^"]+)"/i; $has=($a=~m/\balt=/i)?"yes":"NO"; print "'$f'|$src|$has\n"; }' "$f" >> reports/alt_audit.csv
done
echo "✅ reports/alt_audit.csv"
EOS
chmod +x bin/alt_audit.sh

# ---------- Run passes ----------
[[ -x bin/seo_all.sh ]] && bash bin/seo_all.sh || true
[[ -x bin/schema_site.sh ]] && bash bin/schema_site.sh || true
[[ -x bin/schema_service.sh ]] && bash bin/schema_service.sh || true
[[ -x bin/schema_reports.sh ]] && bash bin/schema_reports.sh || true

bash bin/schema_breadcrumbs.sh
bash bin/schema_faq.sh
bash bin/lazy_images.sh
bash bin/defer_scripts.sh
bash bin/robots_build.sh
[[ -x bin/build_sitemap.sh ]] && bash bin/build_sitemap.sh || true
bash bin/sitemap_html.sh
bash bin/reports_feed.sh
bash bin/svgo_opt.sh
bash bin/image_webp.sh
bash bin/preload_css.sh
[[ -x bin/security_meta.sh ]] && bash bin/security_meta.sh || true
[[ -x bin/hreflang.sh ]] && bash bin/hreflang.sh || true
bash bin/minify_assets.sh

# Optional analytics (set RBIS_PLAUSIBLE_DOMAIN before running if you want it)
[[ -n "${RBIS_PLAUSIBLE_DOMAIN:-}" ]] && bash bin/analytics_plausible.sh || true

# OG + icons (if your existing builders are present)
[[ -x bin/og_build.sh ]] && bash bin/og_build.sh || true
[[ -x bin/icons_build.sh ]] && bash bin/icons_build.sh || true

# ---------- Sanity + commit ----------
echo "🧪 sanity:"
test -s reports.xml && echo "  feed: ✔" || echo "  feed: ✖"
grep -Rqi '<script id="rbis-bc"' . && echo "  breadcrumbs: ✔" || echo "  breadcrumbs: ✖"
grep -Rqi 'application/ld+json' reports.html && echo "  schema reports: ✔" || echo "  schema reports: ✖"
[[ -f robots.txt ]] && echo "  robots.txt: ✔" || echo "  robots.txt: ✖"
[[ -f sitemap.html ]] && echo "  sitemap.html: ✔" || echo "  sitemap.html: ✖"

git add -A || true
git commit -m "coolify+: PWA toggle, robots+sitemap.html, safe defer, FAQ+breadcrumbs hardening, SVGO, WebP, minify, audits ($STAMP)" || true
echo "🚀 Done. Bonus checks: bin/linkcheck.sh • bin/a11y_check.sh • bin/validate_html.sh • bin/alt_audit.sh"
