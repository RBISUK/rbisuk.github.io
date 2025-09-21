#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v cwebp >/dev/null || { echo "ℹ️ cwebp not available; skipping."; exit 0; }
find assets -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | while read -r img; do
  out="${img%.*}.webp"
  if [[ ! -f "$out" || "$img" -nt "$out" ]]; then
    cwebp -quiet -q 82 "$img" -o "$out" && echo "🗜  webp -> $out"
  fi
done
echo "✅ WebP copies generated"
