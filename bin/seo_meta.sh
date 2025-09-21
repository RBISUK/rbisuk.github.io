#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
trap 'rc=$?; echo "❌ ERR seo_meta:$LINENO :: $BASH_COMMAND (rc=$rc)"; exit $rc' ERR
shorten(){ awk -v max=155 '{s=$0; gsub(/^[ \t]+|[ \t]+$/,"",s); if(length(s)>max) s=substr(s,1,max-1)"…"; print s }'; }
desc_for(){ local f="$1"; local t; t=$(sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$f" | head -n1); 
  printf "%s" "$t — RBIS applies behavioural intelligence to reduce fraud, improve trust, and accelerate decisions." | shorten; }
git ls-files '*.html' | while read -r f; do
  [[ -f "$f" ]] || continue
  if ! grep -qi '<meta[^>]*name="description"' "$f"; then
    tmp="$(mktemp)"; awk -v D="$(desc_for "$f")" '
      /<head[^>]*>/ && !done { print; print "  <meta name=\"description\" content=\"" D "\">"; done=1; next }
      { print }' "$f" > "$tmp"
    cp -p "$f" "$f.bak.$(date -u +%Y%m%dT%H%M%SZ)"; mv "$tmp" "$f"; echo "📝 meta -> $f"
  fi
done
echo "✅ meta descriptions ensured"
