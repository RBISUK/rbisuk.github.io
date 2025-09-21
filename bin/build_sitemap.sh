#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
out="sitemap.xml"
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$out"
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> "$out"
for f in $(git ls-files '*.html' | sort); do
  url="$ORIGIN/${f}"
  mod=$(git log -1 --format=%cI -- "$f" 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '  <url><loc>%s</loc><lastmod>%s</lastmod><changefreq>weekly</changefreq></url>\n' "$url" "$mod" >> "$out"
done
echo '</urlset>' >> "$out"
echo "✅ sitemap.xml built ($(wc -l < "$out") lines)"
