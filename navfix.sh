#!/usr/bin/env sh
set -eu

# 1) Ensure disclaimer banner in index.html (right after first <body>)
if ! grep -iq 'not a law firm' index.html 2>/dev/null; then
  awk 'BEGIN{ins=0}
       /<body[^>]*>/ && !ins {
         print $0
         print "<div style=\"background:#FFFBEB;padding:8px;border-bottom:1px solid #FCD34D\"><b>Disclosure:</b> RBIS is not a law firm and does not provide legal advice. We analyse only the evidence in front of our intelligence officers, objectively and without bias.</div>"
         ins=1; next
       }
       {print $0}' index.html > index.tmp && mv index.tmp index.html
fi

# 2) Insert footer quick-links (before </footer>) if not present
if ! grep -q 'Managed Support' index.html 2>/dev/null; then
  awk 'BEGIN{done=0}
       /<\/footer>/ && !done {
         print "<p style=\"text-align:center\"><a href=\"careers.html\">Careers</a> · <a href=\"/articles/\">Articles</a> · <a href=\"managed.html\">Managed Support</a></p>"
         done=1
       }
       {print $0}' index.html > index.tmp && mv index.tmp index.html
fi

echo "navfix ok"
