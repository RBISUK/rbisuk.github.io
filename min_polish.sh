#!/usr/bin/env bash
set -e
echo "PWD=$(pwd)"

# 0) Backup root HTML + assets (best-effort)
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
tar -czf "_backups/html_${STAMP}.tgz" *.html assets 2>/dev/null || true
echo "📦 Backup: _backups/html_${STAMP}.tgz"

# 1) Minify CSS if present (safe, simple)
if [ -f assets/rbis.css ]; then
  sed -E 's:/\*[^*]*\*+([^/*][^*]*\*+)*/::g;s/[[:space:]]+/ /g;s/ *([{};:,]) */\1/g' \
    assets/rbis.css > assets/rbis.min.css
  echo "✅ Minified CSS -> assets/rbis.min.css"
fi

# 2) Add a conservative CSP ONLY to index.html so we can test
CSP="default-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'self' https://api.ipify.org https://hooks.zapier.com; form-action 'self' https://hooks.zapier.com"
if [ -f index.html ]; then
  # drop old CSP meta if any
  sed -i "/http-equiv=[\"']Content-Security-Policy[\"']/Id" index.html || true
  # insert right after <head>
  sed -i "0,/<head[^>]*>/s//&\n  <meta http-equiv=\"Content-Security-Policy\" content=\"$CSP\">/" index.html
  # swap to minified css if present
  if [ -f assets/rbis.min.css ]; then
    sed -i 's#assets/rbis.css#assets/rbis.min.css#g' index.html || true
  fi
  echo "🔒 CSP added to index.html"
else
  echo "ℹ️ index.html not found (skipping CSP)"
fi

# 3) Tiny favicon (harmless); link it if not already linked
cat > favicon.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#6aa8ff"/><stop offset="1" stop-color="#9eff6b"/>
  </linearGradient></defs>
  <rect rx="14" width="64" height="64" fill="#111"/>
  <circle cx="20" cy="22" r="7" fill="url(#g)"/>
  <rect x="30" y="17" width="18" height="10" rx="5" fill="#fff"/>
  <rect x="12" y="36" width="36" height="10" rx="5" fill="#fff" opacity=".9"/>
</svg>
SVG
if [ -f index.html ] && ! grep -qi 'rel="icon"' index.html; then
  sed -i '0,/<head[^>]*>/s//&\n  <link rel="icon" type="image/svg+xml" href="\/favicon.svg">/' index.html
  echo "🖼️ favicon linked on index.html"
fi

# 4) sitemap & robots (SEO)
SITE="https://www.rbisintelligence.com"
{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
  for f in *.html; do echo "  <url><loc>$SITE/$f</loc></url>"; done
  echo '</urlset>'
} > sitemap.xml
echo -e "User-agent: *\nAllow: /\nSitemap: $SITE/sitemap.xml" > robots.txt
echo "🧭 sitemap.xml + robots.txt done"

# 5) commit & push (won’t fail if nothing changed)
git add -A
git commit -m "chore: min polish $(date -u +%Y-%m-%dT%H:%M:%SZ)" || true
git push origin HEAD

# 6) show a couple of HEADs to confirm
curl -sI "$SITE/?v=$(date +%s)" | sed -n '1,8p' || true
curl -sI "$SITE/sitemap.xml?v=$(date +%s)" | sed -n '1,8p' || true

echo "✅ Done."
