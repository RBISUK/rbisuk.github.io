#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v npx >/dev/null || { echo "ℹ️ skipping Lighthouse (no Node)"; exit 0; }
mkdir -p reports/lhci
PORT=8085
python3 -m http.server "$PORT" >/dev/null 2>&1 & srv=$!; trap 'kill $srv 2>/dev/null || true' EXIT
BASE="http://127.0.0.1:$PORT"
# rebase urls to localhost for collection speed
mapfile -t URLS < <(sed -E "s#https?://[^/]+#${BASE}#g" reports/lhci/urls.txt)
# 1) Pretty HTML for the first 8 pages
i=0
for u in "${URLS[@]}"; do
  ((i++)); [[ $i -le 8 ]] || break
  name="$(echo "$u" | sed -E 's#https?://[^/]+/?##; s#[^a-zA-Z0-9._-]+#_#g; s#^$#home#')"
  npx --yes lighthouse "$u" --quiet --chrome-flags="--headless" \
      --preset=desktop --screenEmulation.mobile=false \
      --output html --output-path "reports/lhci/${name}.html" >/dev/null || true
  echo "📊 lighthouse -> reports/lhci/${name}.html"
done
# 2) CI-style budgets & JSON (optional, non-blocking)
npx --yes @lhci/cli@0.13.0 collect --url="${URLS[@]}" \
    --settings.preset=desktop --settings.screenEmulation.mobile=false \
    --collect.numberOfRuns=1 --collect.settings.formFactor=desktop \
    --collect.settings.throttlingMethod=provided \
    --upload.target=filesystem --upload.outputDir=reports/lhci >/dev/null || true
echo "✅ Lighthouse reports in reports/lhci/"
