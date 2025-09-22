#!/usr/bin/env bash
set -euo pipefail

site="https://www.rbisintelligence.com"

# helper: compute canonical route for a given index.html
route_of(){ # prints like "/", "/about/", "/veridex/"
  local f="$1" r="/${f#./}"       # start with "/about/index.html"
  r="${r%index.html}"             # "/about/"
  r="${r:-/}"                     # root case
  r="${r//\/\//\/}"               # collapse slashes
  echo "$r"
}

# iterate over public HTML (skip drafts/ and .git/)
mapfile -t files < <(find . -type f -name "*.html" \
 -not -path "./.git/*" -not -path "./drafts/*" | sort)

for f in "${files[@]}"; do
  # 0) backup once per run
  cp "$f" "$f.bak.$(date -u +%Y%m%dT%H%M%SZ)"

  # 1) ensure <head> exists (minimal) and single <html>/<body> wrapper if missing
  grep -q '<head' "$f" || sed -i '1s#^#<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>RBIS — Behavioural & Intelligence Services</title></head><body>#' "$f"
  grep -q '</body>' "$f" || printf '\n</body>\n' >> "$f"
  grep -q '</html>' "$f" || printf '</html>\n' >> "$f"

  # 2) move/normalise head-ish tags (strip everywhere, then reinsert once inside <head>)
  #    - viewport, theme-color (white), canonical (per file), print.css preload, utility preload
  perl -0777 -pe '
    s/\s*<meta[^>]+name="viewport"[^>]*>\s*//gi;
    s/\s*<meta[^>]+name="theme-color"[^>]*>\s*//gi;
    s/\s*<link[^>]+rel="canonical"[^>]*>\s*//gi;
    s/\s*<link[^>]+print\.css[^>]*>\s*//gi;
    s/\s*<link[^>]+rbis-utility\.css"[^>]*>\s*//gi;
  ' -i "$f"

  canon="$(route_of "$f")"
  head_block=$'<meta charset="utf-8">\n  <meta name="viewport" content="width=device-width,initial-scale=1">\n  <meta name="theme-color" content="#ffffff">\n  <link rel="canonical" href="'"$site$canon"'">\n  <link rel="stylesheet" href="/assets/css/print.css" media="print">\n  <link rel="preload" href="/assets/css/rbis-utility.css" as="style">'

  # ensure there is exactly one <title>; set sensible fallback if missing
  if ! grep -qi '<title>.*</title>' "$f"; then
    sed -i "0,/<head[^>]*>/s//&\n  <title>RBIS — Behavioural & Intelligence Services<\/title>/" "$f"
  fi
  # put our head bits immediately after <head>
  sed -i "0,/<head[^>]*>/s//&\n  $head_block/" "$f"

  # 3) asset & script paths: make root-absolute
  sed -i -E 's#(href|src)="assets/#\1="/assets/#g' "$f"

  # 4) folder-route links (internal): change foo.html → /foo/
  #    Keep external/anchors/mailto untouched.
  perl -0777 -pe '
    s/href="(?!https?:\/\/|mailto:|tel:|#)([^"]+)\.html"/"href=\"\/".($1=~s#^\/?##r).\"\/\""/ge;
  ' -i "$f"

  # 5) enforce <main id="main"> wrapper (skip if already present)
  if ! grep -q '<main[^>]*id="main"' "$f"; then
    awk '
      BEGIN{ins=0}
      /<body[^>]*>/ && !ins {print; print "<main id=\"main\" class=\"main-wrap\">"; ins=1; next}
      /<\/body>/ && ins==1 {print "</main>"; print; next}
      {print}
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi

  # 6) keep only the last </body> (in case earlier injections left dupes)
  awk '{
    if($0 ~ /<\/body>/){b++}
    L[NR]=$0
  }
  END{
    for(i=1;i<=NR;i++){
      if(L[i] ~ /<\/body>/ && b>1){b--; next}
      print L[i]
    }
  }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

# 7) Home-only OG block (fresh, marked). Remove any previous marked block then insert on root index.
idx="index.html"
if [ -f "$idx" ]; then
  sed -i '/<!-- RBIS:OG START -->/,/<!-- RBIS:OG END -->/d' "$idx"
  awk -v s="$site" '
    /<head[^>]*>/ && !done {
      print;
      print "  <!-- RBIS:OG START -->";
      print "  <meta property=\"og:title\" content=\"RBIS — Behavioural & Intelligence Services\">";
      print "  <meta property=\"og:site_name\" content=\"RBIS\">";
      print "  <meta property=\"og:description\" content=\"Evidence-first software & intelligence for repairs, compliance, and audit-ready reporting.\">";
      print "  <meta property=\"og:type\" content=\"website\">";
      print "  <meta property=\"og:locale\" content=\"en_GB\">";
      print "  <meta property=\"og:url\" content=\"" s "/\">";
      print "  <meta property=\"og:image\" content=\"" s "/assets/social/rbis-card.png\">";
      print "  <meta property=\"og:image:width\" content=\"1200\">";
      print "  <meta property=\"og:image:height\" content=\"630\">";
      print "  <meta name=\"twitter:card\" content=\"summary_large_image\">";
      print "  <meta name=\"twitter:title\" content=\"RBIS — Behavioural & Intelligence Services\">";
      print "  <meta name=\"twitter:description\" content=\"Evidence-first software & intelligence for repairs, compliance, and audit-ready reporting.\">";
      print "  <meta name=\"twitter:image\" content=\"" s "/assets/social/rbis-card.png\">";
      print "  <!-- RBIS:OG END -->";
      done=1; next
    } { print }
  ' "$idx" > "$idx.tmp" && mv "$idx.tmp" "$idx"
fi

echo "✅ Normalisation complete."
