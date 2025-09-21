command -v convert >/dev/null || { echo "ℹ️ ImageMagick not found; skipping OG build."; exit 0; }
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
mkdir -p assets/og
logo="assets/og/rbis-logo.png" # optional; put a small transparent logo here if you have one

title(){ sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$1" | head -n1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ; }
slug(){ tr '/ ' '__' <<<"${1%.html}"; }

for f in $(git ls-files '*.html'); do
  [[ -f "$f" ]] || continue
  t="$(title "$f")"; [[ -z "$t" ]] && continue
  s="$(slug "$f")"
  out="assets/og/${s}.png"

  if [[ ! -s "$out" || "$f" -nt "$out" ]]; then
    echo "🎨 building OG: $out"
    convert -size 1200x630 \
      gradient:'#0b0e12-#161c24' \
      -gravity northwest \
      \( -size 1060x480 -background none -fill white -pointsize 64 \
         -interline-spacing 6 caption:"$t" \) -geometry +70+90 -composite \
      -fill '#7cf' -pointsize 26 -gravity southwest -annotate +70+50 'rbisintelligence.com' \
      "$out"
    [[ -f "$logo" ]] && convert "$out" "$logo" -gravity northeast -geometry +50+40 -composite "$out"
  fi

  url="$ORIGIN/${out}"
  alt="Open Graph image for ${t} — RBIS"
  # inject if missing
  if ! grep -qi 'property="og:image"' "$f"; then
    sed -i "0,/<head[^>]*>/{s//&\n  <meta property=\"og:image\" content=\"${url//\//\\/}\">/}" "$f"
  else
    sed -i "s~<meta[^>]*property=\"og:image\"[^>]*>~<meta property=\"og:image\" content=\"${url//\//\\/}\">~I" "$f"
  fi
  grep -qi 'property="og:image:alt"' "$f" || \
    sed -i "0,/<head[^>]*>/{s//&\n  <meta property=\"og:image:alt\" content=\"${alt//\//\\/}\">/}" "$f"
done
echo "✅ OG images built and injected"
