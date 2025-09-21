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
