#!/usr/bin/env sh
set -eu
for f in *.html articles/*.html 2>/dev/null; do
  grep -q 'id="rbis-header"' "$f" 2>/dev/null && continue
  awk 'BEGIN{ins=0}
       /<body[^>]*>/ && !ins {
         print;
         print "<div id=\"rbis-header\" data-active=\"Auto\"></div>";
         print "<link rel=\"stylesheet\" href=\"/assets/header.css\">";
         print "<script defer src=\"/assets/header.js\"><\/script>";
         ins=1; next
       } {print}' "$f" > ".$f.tmp" && mv ".$f.tmp" "$f"
done
echo "header injected where missing"
