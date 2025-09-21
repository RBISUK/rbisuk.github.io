#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
# SVG optimize
if command -v svgo >/dev/null; then
  find assets -type f -name '*.svg' -print0 | xargs -0 -I{} svgo -q {}
fi
# PNG/JPEG losslesss-ish
command -v optipng >/dev/null && find assets -type f -name '*.png' -print0 | xargs -0 -I{} optipng -o2 -quiet {}
command -v jpegoptim >/dev/null && find assets -type f -name '*.jpe\?g' -o -name '*.jpg' -print0 2>/dev/null | xargs -0 -I{} jpegoptim --strip-all --max=90 -q {}
echo "🖼️  image optimization pass done"
