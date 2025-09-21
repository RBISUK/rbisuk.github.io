#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
SNIP='<script id="nav-current">(()=>{try{const p=location.pathname.replace(/index\.html?$/,"");document.querySelectorAll("nav a[href]").forEach(a=>{const href=a.getAttribute("href").replace(/index\.html?$/,"");if(href===p||href===p+"/")a.setAttribute("aria-current","page");});}catch{}})();</script>'
for f in $(git ls-files '*.html'); do
  rg -q 'id="nav-current"' "$f" && continue
  perl -0777 -pe "s#</body>#$SNIP</body>#i" -i "$f"
done
echo "✅ aria-current helper injected"
