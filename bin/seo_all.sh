#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"

die(){ echo "❌ $*" >&2; exit 1; }
bak(){ local f="$1"; cp -p "$f" "$f.bak.$(date -u +%Y%m%dT%H%M%SZ)"; }

ensure_lang(){
  local f="$1"
  if ! grep -qi '<html[^>]*lang=' "$f"; then
    sed -i '0,/<html/{s/<html/<html lang="en-GB" dir="ltr"/}' "$f"
    echo "🌐 lang -> $f"
  fi
}

ensure_head_basics(){
  local f="$1"
  # charset + viewport
  grep -qi '<meta[^>]*charset' "$f" || sed -i '0,/<head[^>]*>/{s//&\n  <meta charset="utf-8">/}' "$f"
  grep -qi 'name="viewport"' "$f" || sed -i '0,/<head[^>]*>/{s//&\n  <meta name="viewport" content="width=device-width,initial-scale=1">/}' "$f"
}

page_title(){ sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$1" | head -n1; }
page_desc(){
  local f="$1"
  local d; d=$(sed -n 's:.*<meta[^>]*name="description"[^>]*content="\([^"]*\)".*:\1:pI' "$f" | head -n1)
  if [[ -z "$d" ]]; then
    local t; t=$(page_title "$f")
    d="$t — RBIS applies behavioural intelligence to reduce fraud, improve trust, and accelerate decisions."
  fi
  # trim to ~160
  python3 - <<PY "$d"
import sys
d=sys.argv[1]
d=d.strip()
print((d[:157]+'…') if len(d)>158 else d)
PY
}

ensure_meta_desc(){
  local f="$1"; local d; d="$(page_desc "$f")"
  grep -qi 'name="description"' "$f" || sed -i "0,/<head[^>]*>/{s//&\n  <meta name=\"description\" content=\"${d//\//\\/}\">/}" "$f"
}

ensure_canonical(){
  local f="$1"; local p; p="/${f#./}"; [[ "$p" == "//*" ]] && p="/"
  local url="$ORIGIN${p}"
  grep -qi 'rel="canonical"' "$f" || sed -i "0,/<head[^>]*>/{s//&\n  <link rel=\"canonical\" href=\"${url//\//\\/}\">/}" "$f"
}

ensure_og_twitter(){
  local f="$1"
  local t; t="$(page_title "$f")"; [[ -z "$t" ]] && t="RBIS • Behavioural & Intelligence Services"
  local d; d="$(page_desc "$f")"
  local p="/${f#./}"; local url="$ORIGIN${p}"
  local og="${ORIGIN}/assets/og/rbis-default.png"
  # if page defines its own og:image keep it; else add default
  if ! grep -qi 'property="og:image"' "$f"; then
    sed -i "0,/<head[^>]*>/{s//&\n  <meta property=\"og:image\" content=\"${og//\//\\/}\">/}" "$f"
  fi
  awk -v T="$t" -v D="$d" -v U="$url" '
    /<head[^>]*>/ && !done++ {
      print;
      print "  <meta property=\"og:title\" content=\"" T "\">";
      print "  <meta property=\"og:description\" content=\"" D "\">";
      print "  <meta property=\"og:url\" content=\"" U "\">";
      print "  <meta property=\"og:site_name\" content=\"RBIS\">";
      print "  <meta property=\"og:type\" content=\"website\">";
      print "  <meta name=\"twitter:card\" content=\"summary_large_image\">";
      print "  <meta name=\"twitter:title\" content=\"" T "\">";
      print "  <meta name=\"twitter:description\" content=\"" D "\">";
      next
    }{print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

ensure_robots_policy(){
  local f="$1"
  case "$f" in
    404.html) # keep 404 out of index
      grep -qi 'name="robots"' "$f" || sed -i '0,/<head[^>]*>/{s//&\n  <meta name="robots" content="noindex,follow">/}' "$f"
      ;;
  esac
}

ensure_skip_link(){
  local f="$1"
  grep -qi 'id="skip-to-content"' "$f" && return 0
  awk '
    BEGIN{done=0}
    /<body[^>]*>/ && !done {
      print;
      print "  <a id=\"skip-to-content\" class=\"skip\" href=\"#main\" style=\"position:absolute;left:-9999px;top:-9999px\">Skip to content</a>";
      done=1; next
    }{print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  # ensure <main id="main">
  grep -qi '<main' "$f" && sed -i '0,/<main/{s/<main/<main id="main"/}' "$f" || true
}

for f in $(git ls-files '*.html'); do
  [[ -f "$f" ]] || continue
  bak "$f"
  ensure_lang "$f"
  ensure_head_basics "$f"
  ensure_meta_desc "$f"
  ensure_canonical "$f"
  ensure_og_twitter "$f"
  ensure_robots_policy "$f"
  ensure_skip_link "$f"
done

echo "✅ SEO basics + OG/Twitter + canonical + a11y skip link ensured"
