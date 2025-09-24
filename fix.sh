#!/usr/bin/env sh
# ensure managed.html ends properly
grep -q '</html>' managed.html 2>/dev/null || printf '\n</body></html>\n' >> managed.html
# ensure disclaimer on index.html (inject right after <body ...>)
grep -iq 'not a law firm' index.html 2>/dev/null || \
sed -i '0,/<body[^>]*>/{s##&\
<div style="background:#FFFBEB;padding:8px;border-bottom:1px solid #FCD34D"><b>Disclosure:</b> RBIS is not a law firm and does not provide legal advice. We analyse only the evidence in front of our intelligence officers, objectively and without bias.</div>#}' index.html
echo "fixes applied"
