#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

mkdir -p assets/css

# Tailwind config + input (created once, reused later)
[[ -f tailwind.config.js ]] || cat > tailwind.config.js <<'CFG'
module.exports = {
  content: ["**/*.html","assets/**/*.js"],
  theme: { extend: {} },
  corePlugins: { preflight: true }
}
CFG

[[ -f assets/css/tw-input.css ]] || cat > assets/css/tw-input.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;
CSS

# Require Node; bail gracefully if missing
command -v node >/dev/null || { echo "ℹ️ Node not found; skipping Tailwind build"; exit 0; }

# Build purged + minified CSS via npx (no package.json required)
npx --yes tailwindcss -i assets/css/tw-input.css -o assets/css/tw.min.css --minify

# SRI
if command -v openssl >/dev/null; then
  SRI=$(openssl dgst -sha384 -binary assets/css/tw.min.css | openssl base64 -A)
  echo "$SRI" > assets/css/tw.min.css.sha384
fi

# Remove Tailwind CDN tags and inject local stylesheet (idempotent)
for f in $(git ls-files '*.html'); do
  # Remove any <script src="https://cdn.tailwindcss.com">...</script>
  perl -0777 -pe 's#<script[^>]*src="https://cdn\.tailwindcss\.com[^"]*"[^>]*>\s*</script>\s*##ig' -i "$f"

  # Add stylesheet if not present
  if ! grep -qi 'assets/css/tw\.min\.css' "$f"; then
    if [[ -f assets/css/tw.min.css.sha384 ]]; then
      SRI_VAL=$(cat assets/css/tw.min.css.sha384)
      perl -0777 -pe 's#</head>#<link rel="preload" as="style" href="/assets/css/tw.min.css">\n<link rel="stylesheet" href="/assets/css/tw.min.css" integrity="sha384:'"$SRI_VAL"'" crossorigin>\n</head>#i' -i "$f"
    else
      perl -0777 -pe 's#</head>#<link rel="preload" as="style" href="/assets/css/tw.min.css">\n<link rel="stylesheet" href="/assets/css/tw.min.css">\n</head>#i' -i "$f"
    fi
  fi
done

echo "✅ Tailwind: local, purged, minified, SRI added"
