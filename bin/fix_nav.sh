#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

die(){ echo "❌ $*" >&2; exit 1; }
bak(){ local f="$1"; [[ -f "$f" ]] || die "No such file: $f"; local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"; cp -p "$f" "${f}.bak.${ts}"; echo "🛟 Backup -> ${f}.bak.${ts}"; }

FILE="${1:-index.html}"
[[ -f "$FILE" ]] || die "Missing $FILE"

# 1) Un-hide existing <nav> by removing hiding attrs/classes
tmp="$(mktemp)"
awk 'BEGIN{IGNORECASE=1}
     {
       line=$0
       # strip attributes that hide nav
       gsub(/ hidden(=("[^"]*"|'\''[^'\'']*'\''))?/,"",line)
       gsub(/ aria-hidden(=("[^"]*"|'\''[^'\'']*'\''))?/,"",line)
       # strip sr-only/visually-hidden/hidden tokens from class on <nav>
       if (line ~ /<nav[^>]*class="/) {
         match(line,/class="[^"]*"/)
         if (RSTART>0) {
           cls=substr(line,RSTART,RLENGTH)
           gsub(/sr-only|visually-hidden|(^| )hidden( |$)/,"",cls)
           gsub(/  +/," ",cls)
           gsub(/class=" *"/,"",cls)
           line = substr(line,1,RSTART-1) cls substr(line,RSTART+RLENGTH)
         }
       }
       print line
     }' "$FILE" > "$tmp"

# Only swap if nav exists or we actually changed something
if grep -qi '<nav[^>]*>' "$FILE"; then
  bak "$FILE"
  mv "$tmp" "$FILE"
else
  rm -f "$tmp"
fi

# 2) If still no <nav>, inject a minimal semantic one (no styling)
if ! grep -qi '<nav[^>]*>' "$FILE"; then
  tmp2="$(mktemp)"
  awk '
    BEGIN{done=0}
    /<header[^>]*>/ && done==0 { 
      print
      print "<nav aria-label=\"Primary\"><a class=\"brand\" href=\"/index.html\">RBIS</a><ul><li><a href=\"/solutions.html\">Solutions</a></li><li><a href=\"/reports.html\">Reports</a></li><li><a href=\"/products.html\">Products</a></li><li><a href=\"/about.html\">About</a></li><li><a href=\"/contact.html\">Contact</a></li></ul></nav>"
      done=1; next
    }
    { print }
    END{
      if(done==0){
        print "<nav aria-label=\"Primary\"><a class=\"brand\" href=\"/index.html\">RBIS</a><ul><li><a href=\"/solutions.html\">Solutions</a></li><li><a href=\"/reports.html\">Reports</a></li><li><a href=\"/products.html\">Products</a></li><li><a href=\"/about.html\">About</a></li><li><a href=\"/contact.html\">Contact</a></li></ul></nav>"
      }
    }
  ' "$FILE" > "$tmp2"
  bak "$FILE"
  mv "$tmp2" "$FILE"
fi

echo "✅ Navbar ensured/unhidden in $FILE (no CSS changes)"
