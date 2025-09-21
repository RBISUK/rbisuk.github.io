#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
NAME="${RBIS_ORG_NAME:-RBIS}"
LOGO="${RBIS_ORG_LOGO:-/assets/logo.svg}"
SITE=$(cat <<JSON
<script id="rbis-site" type="application/ld+json">
{"@context":"https://schema.org",
 "@type":"WebSite",
 "url":"$ORIGIN/",
 "name":"$NAME",
 "potentialAction":{
   "@type":"SearchAction",
   "target":"$ORIGIN/search.html?q={search_term_string}",
   "query-input":"required name=search_term_string"}}
</script>
JSON
)
ORG=$(cat <<JSON
<script id="rbis-org" type="application/ld+json">
{"@context":"https://schema.org",
 "@type":"Organization",
 "url":"$ORIGIN/",
 "name":"$NAME",
 "logo":"$ORIGIN$LOGO"}
</script>
JSON
)
for f in $(git ls-files '*.html'); do
  awk -v A="$SITE" -v B="$ORG" '
    BEGIN{has1=0;has2=0;skip1=0;skip2=0}
    /<script id="rbis-site"/{has1=1; skip1=1}
    skip1 && /<\/script>/{skip1=0; next}
    /<script id="rbis-org"/{has2=1; skip2=1}
    skip2 && /<\/script>/{skip2=0; next}
    /<\/head>/{
      if(!has1) print A;
      if(!has2) print B;
      print; next
    }
    { if(!skip1 && !skip2) print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ org+site schema -> $f"
done
