#!/usr/bin/env bash
set -Eeuo pipefail
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
f="products.html"
test -f "$f" || { echo "✖ $f missing"; exit 1; }
cp -f "$f" "_backups/$f.$STAMP"

# 1) Add Product JSON-LD for Veridex (once)
if ! grep -q '"@type":"Product"' "$f"; then
  awk -v RS= -v ORS= '
   /<\/head>/{ sub(/<\/head>/,
   "<script type=\"application/ld+json\">{\n" \
   " \"@context\":\"https://schema.org\",\n" \
   " \"@type\":\"Product\",\"name\":\"Veridex Funnel\",\n" \
   " \"brand\":{\"@type\":\"Brand\",\"name\":\"RBIS\"},\n" \
   " \"description\":\"Configurable intake + compliance logic + audit trail for public-facing funnels.\",\n" \
   " \"category\":\"Sales Funnel\",\n" \
   " \"url\":\"https://www.rbisintelligence.com/products.html#veridex\",\n" \
   " \"offers\":{\"@type\":\"Offer\",\"price\":\"POA\",\"priceCurrency\":\"GBP\",\"availability\":\"https://schema.org/InStock\"}\n" \
   "}</script>\n</head>") }1' "$f" > .tmp && mv .tmp "$f"
fi

# 2) Insert a featured band at the top of <main> (idempotent)
if ! grep -q 'id="feature-veridex"' "$f"; then
  awk -v RS= -v ORS= '
    /<main[^>]*>/ && !done {
      done=1; print;
      print "<section id=\"feature-veridex\" class=\"section card\" style=\"display:flex;gap:22px;align-items:center;flex-wrap:wrap;margin-top:14px\">";
      print " <div style=\"flex:1 1 420px;min-width:280px\">";
      print "  <span class=\"badge\">Featured</span>";
      print "  <h2 style=\"margin:10px 0 6px\">Veridex Funnel</h2>";
      print "  <p>Public sales funnel with pre-programmed compliance logic, industry presets, and an audit trail. Easy to configure, fast to deploy.</p>";
      print "  <div style=\"display:flex;gap:10px;flex-wrap:wrap\">";
      print "    <a class=\"btn\" href=\"/veridex-demo.html\">Try demo</a>";
      print "    <a class=\"btn\" style=\"background:linear-gradient(180deg,#9ae7ff,#7cc4ff)\" href=\"/contact.html?utm_source=site&utm_medium=cta&utm_campaign=veridex\">Talk to us</a>";
      print "  </div>";
      print " </div>";
      print " <img class=\"crest-spin\" src=\"/assets/logo.svg\" alt=\"Veridex crest\" style=\"width:96px;height:96px\">";
      print "</section>";
      next
    }1' "$f" > .tmp && mv .tmp "$f"
fi

echo "✓ products polished ($STAMP)"
