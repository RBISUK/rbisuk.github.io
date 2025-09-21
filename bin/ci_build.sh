#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

echo "▶ CI build start"

# Hard bail if we accidentally run inside reports/
[[ "$(pwd)" =~ reports(/|$)? ]] && { echo "Refusing to run inside reports/"; exit 1; }

# Bring Tailwind local (purged/minified + SRI)
[[ -x bin/tailwind_local.sh ]] || {
  cat > bin/tailwind_local.sh <<'TW'
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p assets/css
[[ -f tailwind.config.js ]] || cat > tailwind.config.js <<'CFG'
module.exports = { content: ["**/*.html","assets/**/*.js"], theme: { extend: {} }, corePlugins: { preflight: true } }
CFG
[[ -f assets/css/tw-input.css ]] || printf '%s\n' '@tailwind base;' '@tailwind components;' '@tailwind utilities;' > assets/css/tw-input.css
if command -v node >/dev/null; then
  npx --yes tailwindcss -i assets/css/tw-input.css -o assets/css/tw.min.css --minify
  if command -v openssl >/dev/null; then
    openssl dgst -sha384 -binary assets/css/tw.min.css | openssl base64 -A > assets/css/tw.min.css.sha384
  fi
  for f in $(git ls-files '*.html'); do
    # remove CDN tailwind, inject local once
    perl -0777 -pe 's#<script[^>]*src="https://cdn\.tailwindcss\.com[^"]*"[^>]*>\s*</script>\s*##ig' -i "$f"
    if ! grep -qi 'assets/css/tw\.min\.css' "$f"; then
      if [[ -f assets/css/tw.min.css.sha384 ]]; then
        SRI=$(cat assets/css/tw.min.css.sha384)
        perl -0777 -pe 's#</head>#<link rel="preload" as="style" href="/assets/css/tw.min.css">\n<link rel="stylesheet" href="/assets/css/tw.min.css" integrity="sha384:'"$SRI"'" crossorigin>\n</head>#i' -i "$f"
      else
        perl -0777 -pe 's#</head>#<link rel="preload" as="style" href="/assets/css/tw.min.css">\n<link rel="stylesheet" href="/assets/css/tw.min.css">\n</head>#i' -i "$f"
      fi
    fi
  done
  echo "✅ Tailwind: local build + SRI"
else
  echo "ℹ️ Node not found; skipping Tailwind build"
fi
TW
  chmod +x bin/tailwind_local.sh
}
bash bin/tailwind_local.sh

# Preconnect hints (dedup)
[[ -x bin/preconnect.sh ]] && bash bin/preconnect.sh || true

# SRI for any other static assets (noop if none)
[[ -x bin/sri_inject.sh ]] && bash bin/sri_inject.sh || true

# CSP (Report-Only, safe)
[[ -x bin/csp_harden.sh ]] && bash bin/csp_harden.sh || true

# Accessibility reports (but never write into reports under reports/)
[[ -x bin/a11y_pa11y.sh ]] && bash bin/a11y_pa11y.sh || true

# Clean any accidental nested a11y paths (*.html.html or /reports/a11y/**/reports/a11y/**)
find reports/a11y -type f -name '*.html.html' -delete 2>/dev/null || true
find reports/a11y -type d -path '*/reports/a11y/*' -print0 2>/dev/null | xargs -0r rm -rf || true

# Sitemap + HTML sitemap + index
[[ -x bin/build_sitemap.sh ]] && bash bin/build_sitemap.sh || true
[[ -x bin/build_sitemap_index.sh ]] && bash bin/build_sitemap_index.sh || true

# Atom feed for /reports (safe if script exists)
[[ -x bin/reports_feed.sh ]] && bash bin/reports_feed.sh || true

# Page checks CSV
[[ -x bin/page_check.sh ]] && bash bin/page_check.sh || true

echo "✅ CI build done"
