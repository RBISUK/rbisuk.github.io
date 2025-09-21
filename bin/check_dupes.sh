#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
out="reports/dupes.txt"; : > "$out"
echo "# Duplicate tag scan" >> "$out"
for f in $(git ls-files '*.html'); do
  can=$(rg -Noc '<link[^>]+rel="canonical"' "$f" || true)
  desc=$(rg -Noc '<meta[^>]+name="description"' "$f" || true)
  jsonld=$(rg -No '<script[^>]+type="application/ld\+json"[^>]*id="([^"]+)"' "$f" | awk '{print $2}' | sort | uniq -d || true)
  [[ "${can:-0}" -gt 1 ]] && echo "$f: canonical x${can}" >> "$out"
  [[ "${desc:-0}" -gt 1 ]] && echo "$f: description x${desc}" >> "$out"
  [[ -n "$jsonld" ]] && echo "$f: duplicate JSON-LD ids -> $jsonld" >> "$out"
done
echo "📄 wrote $out"
