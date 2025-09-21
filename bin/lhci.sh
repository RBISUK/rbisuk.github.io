#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
OUT="reports/lhci"; mkdir -p "$OUT"
if ! command -v node >/dev/null; then echo "ℹ️ Node not found; skipping LHCI"; exit 0; fi
CHROME=""
for c in google-chrome chromium chromium-browser; do command -v "$c" >/dev/null && CHROME="$c" && break; done
[[ -z "$CHROME" ]] && { echo "ℹ️ Chrome/Chromium not found; skipping LHCI"; exit 0; }
PORT="${PORT:-4173}"
npx --yes http-server -p "$PORT" -s . >/dev/null 2>&1 & SRV=$!
trap 'kill $SRV 2>/dev/null || true' EXIT
sleep 1
mapfile -t URLS < <(git ls-files '*.html' | sed "s#^#http://localhost:${PORT}/#")
# limit to first 15 pages
ARGS=()
i=0; for u in "${URLS[@]}"; do ARGS+=(--url="$u"); i=$((i+1)); [[ $i -ge 15 ]] && break; done
npx --yes @lhci/cli collect "${ARGS[@]}" --numberOfRuns=1 --settings.chromePath="$(command -v "$CHROME")" --settings.emulatedFormFactor=desktop --output-dir="$OUT" || true
echo "✅ LHCI (if Chrome present) -> $OUT"
