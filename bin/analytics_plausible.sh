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
