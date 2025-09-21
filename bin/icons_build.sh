command -v convert >/dev/null || { echo "ℹ️ ImageMagick not found; skipping icon build."; exit 0; }
#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
mkdir -p assets/icons
base="assets/og/index.png"
[[ -f "$base" ]] || base="assets/og/index_html.png"
[[ -f "$base" ]] || { echo "Tip: After running bin/og_build.sh you’ll have a base OG we can resize."; }

gen(){ local s="$1" n="$2"; convert "${base:-xc:#11161c}" -resize ${s}x${s}\! "assets/icons/$n"; }
gen 180 apple-touch-icon.png
gen 192 android-chrome-192x192.png
gen 512 android-chrome-512x512.png
convert assets/icons/android-chrome-192x192.png assets/icons/android-chrome-512x512.png assets/icons/favicon.ico

cat > manifest.json <<JSON
{
  "name": "RBIS",
  "short_name": "RBIS",
  "icons": [
    {"src": "/assets/icons/android-chrome-192x192.png","sizes":"192x192","type":"image/png"},
    {"src": "/assets/icons/android-chrome-512x512.png","sizes":"512x512","type":"image/png"}
  ],
  "theme_color":"#0b0e12","background_color":"#0b0e12","display":"standalone","start_url":"/"
}
JSON

for f in $(git ls-files '*.html'); do
  awk '
    /<head[^>]*>/ && !done++ {
      print;
      print "  <link rel=\"icon\" href=\"/assets/icons/favicon.ico\">";
      print "  <link rel=\"apple-touch-icon\" href=\"/assets/icons/apple-touch-icon.png\">";
      print "  <link rel=\"manifest\" href=\"/manifest.json\">";
      print "  <meta name=\"theme-color\" content=\"#0b0e12\">";
      next
    } {print}
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "✅ icons + manifest injected"
