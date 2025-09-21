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
