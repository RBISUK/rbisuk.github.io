#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

PORT="${PORT:-8080}"
OUT="${OUT:-reports}"
mkdir -p "$OUT" || true

need() { command -v "$1" >/dev/null || echo "ℹ️ $1 not found"; }

echo "➡️  Installing CLIs (temp, via npx when possible)…"
need tidy || { echo "Install tidy for HTML validation: sudo apt-get install tidy"; }

npx http-server -p "$PORT" --silent & srv=$!
cleanup(){ kill $srv 2>/dev/null || true; }
trap cleanup EXIT

echo "⏳ waiting for http://127.0.0.1:$PORT/"
for i in {1..30}; do curl -sf "http://127.0.0.1:$PORT/" && break || sleep 1; done

# Build URL list
if [[ -f sitemap.xml ]]; then
  python3 - <<'PY' > /tmp/urls.txt
import xml.etree.ElementTree as ET
r=ET.parse('sitemap.xml').getroot()
ns={'s':'http://www.sitemaps.org/schemas/sitemap/0.9'}
for loc in r.findall('.//s:url/s:loc', ns):
    print(loc.text.strip())
PY
else
  find . -type f -name '*.html' -not -path './node_modules/*' -not -path './.git/*' \
    | sed 's|^\./||' | sort -u | sed "s|^|http://127.0.0.1:${PORT}/|" > /tmp/urls.txt
fi
echo "🔗 URLs: $(wc -l </tmp/urls.txt)"

mkdir -p "$OUT/html" "$OUT/a11y" "$OUT/axe" "$OUT/links" "$OUT/lighthouse" "$OUT/jsonld"

# HTML validate
if need tidy >/dev/null 2>&1; then
  for f in $(git ls-files '*.html'); do
    tidy -qe -utf8 "$f" >"$OUT/html/$(echo "$f" | tr '/' '_').txt" 2>&1 || true
  done
fi

# pa11y
head -n 100 /tmp/urls.txt | jq -R . | jq -s '{defaults:{standard:"WCAG2AA","timeout":60000}, urls:.}' > /tmp/.pa11yci.json
npx pa11y-ci --config /tmp/.pa11yci.json > "$OUT/a11y/summary.txt" 2>&1 || true

# axe (sample)
while read -r u; do
  npx axe --chromium --timeout 60000 "$u" > "$OUT/axe/$(echo "$u" | sed 's|https\?://||; s|/|_|g').json" || true
done < <(head -n 30 /tmp/urls.txt)

# linkinator
npx linkinator "http://127.0.0.1:${PORT}" --recurse --skip 'mailto:,tel:' --timeout 300000 --verbosity error > "$OUT/links/report.txt" || true

# Lighthouse (top 5)
for u in $(head -n 5 /tmp/urls.txt); do
  safe=$(echo "$u" | sed 's|https\?://||; s|/|_|g')
  npx lhci collect --url="$u" --settings.preset=desktop --outputPath="$OUT/lighthouse/${safe}-desktop" || true
  npx lhci collect --url="$u" --settings.preset=mobile  --outputPath="$OUT/lighthouse/${safe}-mobile"  || true
done

# JSON-LD lint
node - <<'JS' > "$OUT/jsonld/parse.txt"
const fs=require('fs'); const glob=require('glob');
for (const f of glob.sync('**/*.html',{ignore:['node_modules/**','.git/**']})) {
  const html=fs.readFileSync(f,'utf8');
  const re=/<script[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi;
  let m; while ((m=re.exec(html))) {
    try { JSON.parse(m[1]); } catch(e){ console.log(`[JSONLD] ${f}: ${e.message}`); }
  }
}
JS

echo "✅ Local reports written to $OUT/"
echo "   Broken links?   -> $OUT/links/report.txt"
echo "   A11y summary    -> $OUT/a11y/summary.txt"
echo "   JSON-LD errors  -> $OUT/jsonld/parse.txt"
