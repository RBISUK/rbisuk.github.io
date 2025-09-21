#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

echo "🏁 RBIS coolify starting…"

# -------- config --------
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
backup(){ [[ -f "$1" ]] && cp -p "$1" "$1.bak.$STAMP" || true; }

# -------- detect & install packages (best-effort, cross-platform) --------
pm=""
if command -v apt-get >/dev/null; then pm="apt"
elif command -v brew >/dev/null; then pm="brew"
elif command -v choco >/dev/null; then pm="choco"
fi

install(){
  case "$pm" in
    apt)
      sudo apt-get update -y
      sudo apt-get install -y \
        imagemagick pngquant optipng jpegoptim webp gifsicle \
        exiftool jq xmlstarlet parallel tidy \
        curl ripgrep nodejs npm python3 python3-pip
      ;;
    brew)
      brew install imagemagick pngquant optipng jpegoptim webp gifsicle \
        exiftool jq xmlstarlet gnu-parallel tidy-html5 \
        curl ripgrep node python
      ;;
    choco)
      choco install -y imagemagick pngquant optipng jpegoptim webp gifsicle \
        exiftool jq xmlstarlet gow \
        curl ripgrep nodejs python
      ;;
    *)
      echo "⚠️  No known package manager found; skipping system installs."
      ;;
  esac
}

echo "📦 Installing system tools (idempotent)…"
install || true

# -------- npm CLIs (local devDeps via npx-friendly) --------
if command -v npm >/dev/null; then
  # Use local dev deps if package.json exists; otherwise global fallback is via npx download-on-use.
  if [[ -f package.json ]]; then
    echo "📦 Installing node devDeps…"
    npm pkg set private=true >/dev/null 2>&1 || true
    npm add -D svgo html-minifier-terser clean-css-cli uglify-js \
      linkinator pa11y-ci @lhci/cli >/dev/null 2>&1 || true
  fi
else
  echo "ℹ️ npm not found; skipping node devDeps (npx will still work if npm appears later)."
fi

# -------- minor CSS fix guard (your earlier glitch) --------
if [[ -f assets/rbis.css ]]; then
  backup assets/rbis.css
  perl -0777 -pe 's/body\{margin:0[^}]*\}/body{margin:0;background:var(--bg);color:var(--text);font:var(--s1)\/var(--lh) var(--font);}/' \
    -i assets/rbis.css || true
fi

# -------- create/refresh helper scripts (idempotent) --------

mkdir -p bin assets/og assets/icons

# 1) Breadcrumbs JSON-LD
cat > bin/schema_breadcrumbs.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
cap(){ awk -F'-' '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } print}' <<<"$1" | sed 's/&/ & /g;s/  */ /g'; }
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
  leaf="$(title_for "$f")"; [[ -z "$leaf" ]] && leaf="$(basename "$f" .html | sed 's/-/ /g' | cap)"
  crumbs+=( "{\"@type\":\"ListItem\",\"position\":$((pos++)),\"name\":\"$leaf\",\"item\":\"$url\"}" )
  SCHEMA=$(cat <<JSON
<script id="rbis-bc" type="application/ld+json">
{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[${crumbs[*]}]}
</script>
JSON
)
  awk -v B="$SCHEMA" '
    BEGIN{done=0;skip=0}
    /<script id="rbis-bc"/{ if(!done){print B; done=1} ; skip=1 }
    skip && /<\/script>/ { skip=0; next }
    /<\/head>/ && !done { print B; print; done=1; next }
    { if(!skip) print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ breadcrumbs -> $f"
done
EOS
chmod +x bin/schema_breadcrumbs.sh

# 2) Lazy images
cat > bin/lazy_images.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's/<img(?![^>]*\bloading=)([^>]*?)>/sprintf("<img loading=\"lazy\" decoding=\"async\"%s>",$1)/eig' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "✅ loading=\"lazy\" + decoding=\"async\" added to <img>"
EOS
chmod +x bin/lazy_images.sh

# 3) Reports Atom feed (fixed heredoc)
cat > bin/reports_feed.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
FILE="reports.html"; [[ -f "$FILE" ]] || { echo "no reports.html"; exit 0; }
DATA="$(awk '/<script id="report-data"/,/<\/script>/' "$FILE" | sed '1d;$d')"
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

# 4) FAQPage JSON-LD from <details><summary> pairs
cat > bin/schema_faq.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
for f in $(git ls-files '*.html'); do
  qs=$(grep -o '<summary>[^<]\+</summary>' "$f" || true)
  [[ -z "$qs" ]] && continue
  body="$(awk '1' "$f")"
  # Capture Q/A blocks
  mapfile -t blocks < <(perl -0777 -ne 'while (m|<details>(.*?)</details>|sg){print "$1\n---\n"}' "$f")
  items=(); count=0
  for b in "${blocks[@]}"; do
    q=$(sed -n 's/.*<summary>\(.*\)<\/summary>.*/\1/p' <<<"$b")
    a=$(sed -n 's/.*<\/summary>\(.*\)$/\1/p' <<<"$b" | sed 's/<[^>]*>//g' | tr -s ' ' ' ' | sed 's/^ *//;s/ *$//')
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
    /<script id="rbis-faq"/{ if(!done){print B; done=1} ; skip=1 }
    skip && /<\/script>/ { skip=0; next }
    /<\/head>/ && !done { print B; print; done=1; next }
    { if(!skip) print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ FAQ schema -> $f ($count Q/A)"
done
EOS
chmod +x bin/schema_faq.sh

# 5) Generate WebP copies (non-destructive; HTML unchanged)
cat > bin/image_webp.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v cwebp >/dev/null || { echo "ℹ️ libwebp not available (cwebp); skipping."; exit 0; }
find assets -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | while read -r img; do
  out="${img%.*}.webp"
  if [[ ! -f "$out" || "$img" -nt "$out" ]]; then
    cwebp -quiet -q 82 "$img" -o "$out" && echo "🗜  webp -> $out"
  fi
done
echo "✅ WebP copies generated (HTML unchanged)"
EOS
chmod +x bin/image_webp.sh

# 6) Minify (safe flags; backups kept)
cat > bin/minify_assets.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
has(){ command -v "$1" >/dev/null; }
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

# 7) Link check (against live origin) + A11Y spot check
cat > bin/linkcheck.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
if ! command -v npx >/dev/null; then echo "npx missing"; exit 0; fi
npx --yes linkinator "$ORIGIN" --recurse --timeout 10000 --silent || true
EOS
chmod +x bin/linkcheck.sh

cat > bin/a11y_check.sh <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
if ! command -v npx >/dev/null; then echo "npx missing"; exit 0; fi
URLS=(
  "https://www.rbisintelligence.com/"
  "https://www.rbisintelligence.com/reports.html"
  "https://www.rbisintelligence.com/products.html"
  "https://www.rbisintelligence.com/trust/security/overview.html"
)
for u in "${URLS[@]}"; do
  echo "🔎 pa11y $u"
  npx --yes pa11y-ci --sitemap "$u" --threshold 5 || true
done
EOS
chmod +x bin/a11y_check.sh

# -------- OG cards + icons (your existing builders) --------
if [[ -x bin/og_build.sh ]]; then bash bin/og_build.sh || true; fi
if [[ -x bin/icons_build.sh ]]; then bash bin/icons_build.sh || true; fi

# -------- Site-wide polish passes (existing + new) --------
[[ -x bin/seo_all.sh ]] && bash bin/seo_all.sh || true
[[ -x bin/schema_site.sh ]] && bash bin/schema_site.sh || true
[[ -x bin/schema_service.sh ]] && bash bin/schema_service.sh || true
[[ -x bin/schema_reports.sh ]] && bash bin/schema_reports.sh || true
bash bin/schema_breadcrumbs.sh
bash bin/schema_faq.sh
bash bin/lazy_images.sh
[[ -x bin/security_meta.sh ]] && bash bin/security_meta.sh || true
[[ -x bin/hreflang.sh ]] && bash bin/hreflang.sh || true
[[ -x bin/build_sitemap.sh ]] && bash bin/build_sitemap.sh || true
bash bin/reports_feed.sh || true
bash bin/image_webp.sh || true
bash bin/minify_assets.sh || true

# -------- sanity + commit --------
echo "🧪 quick sanity:"
test -s reports.xml && echo "   feed: present ✔" || echo "   feed: missing ✖"
grep -Rqi '<script id="rbis-bc"' . && echo "   breadcrumbs: ✔" || echo "   breadcrumbs: ✖"
grep -Rqi 'application/ld+json' reports.html && echo "   schema on reports: ✔" || echo "   schema on reports: ✖"

git add -A || true
git commit -m "coolify: full tooling install; FAQ+breadcrumbs schema; lazy images; OG+icons; WebP; minify; feed; SEO passes ($STAMP)" || true

echo "🚀 Done. Suggested follow-ups:"
echo "   • Run: bin/linkcheck.sh   (external link health)"
echo "   • Run: bin/a11y_check.sh  (spot-check accessibility)"
echo "   • Verify: https://www.rbisintelligence.com/reports.xml"
