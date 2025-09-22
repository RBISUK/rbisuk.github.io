#!/usr/bin/env bash
set -euo pipefail
f="$1"

# 1) Ensure <head> has viewport + utility css (idempotent)
if ! grep -q 'rbis-utility.css' "$f"; then
  awk '
  BEGIN{done=0}
  /<head[^>]*>/ && !done {
    print; 
    print "  <meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">";
    print "  <link rel=\"stylesheet\" href=\"/assets/css/rbis-utility.css\">";
    done=1; next
  }
  {print}
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
fi

# Load partials
H="$(cat partials/header.html 2>/dev/null || true)"
F="$(cat partials/footer.html 2>/dev/null || true)"
[ -n "$H" ] && [ -n "$F" ] || { echo "Missing partials. Make header/footer first."; exit 1; }

# 2) Inject header right after <body ...>
awk -v H="$H" '
BEGIN{ins=0}
{
  if(!ins && $0 ~ /<body[^>]*>/){ print; print "<!-- RBIS:header -->"; print H; print "<!-- RBIS:endheader -->"; ins=1; next }
  print
}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

# 3) Inject footer just before </body>
awk -v F="$F" '
{
  if($0 ~ /<\/body>/){
    print "<!-- RBIS:footer -->"; print F; print "<!-- RBIS:endfooter -->"
  }
  print
}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

echo "Injected: $f"
