#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
command -v identify >/dev/null || { echo "ℹ️ ImageMagick not found; skipping"; exit 0; }
for f in $(git ls-files '*.html'); do
  tmp="$f.tmp"; cp "$f" "$tmp"
  while read -r tag src; do
    [[ "$src" == /* ]] || continue
    p=".$src"; [[ -f "$p" ]] || continue
    grep -qE '<img[^>]*\b(width|height)=' <<<"$tag" && continue
    WH="$(identify -format '%w %h' "$p" 2>/dev/null || true)"; [[ -z "$WH" ]] && continue
    W="${WH%% *}"; H="${WH##* }"
    perl -0777 -pe "s#<img([^>]*?)src=\"$src\"([^>]*?)>#<img\1src=\"$src\" width=\"$W\" height=\"$H\"\2>#g" -i "$tmp"
  done < <(rg -No '<img[^>]+src="([^"]+)"[^>]*>' "$f" | awk -F'"' '{print $0" "$2}')
  if ! diff -q "$f" "$tmp" >/dev/null; then mv "$tmp" "$f"; else rm -f "$tmp"; fi
done
echo "✅ width/height added for local images"
