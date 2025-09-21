#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
searchUrl="$ORIGIN/search.html?q={search_term_string}"
schema=$(cat <<JSON
{
  "@context":"https://schema.org",
  "@graph":[
    {
      "@type":"WebSite",
      "@id":"$ORIGIN/#website",
      "url":"$ORIGIN/",
      "potentialAction":{
        "@type":"SearchAction",
        "target":"$searchUrl",
        "query-input":"required name=search_term_string"
      }
    },
    {
      "@type":"Organization",
      "@id":"$ORIGIN/#org",
      "name":"RBIS Intelligence",
      "url":"$ORIGIN/",
      "logo":{"@type":"ImageObject","url":"$ORIGIN/assets/icons/apple-touch-icon.png"},
      "sameAs":[
        "https://x.com/rbisuk",
        "https://www.linkedin.com/company/rbis-intelligence"
      ],
      "contactPoint":[{
        "@type":"ContactPoint",
        "contactType":"customer support",
        "email":"info@rbisintelligence.com",
        "url":"$ORIGIN/contact.html",
        "availableLanguage":["en"]
      }]
    }
  ]
}
JSON
)
for f in $(git ls-files '*.html'); do
  # upsert block with a stable id
  if rg -q 'id="schema-website-org"' "$f"; then
    perl -0777 -pe 's#<script[^>]*id="schema-website-org"[^>]*>.*?</script>#<script type="application/ld+json" id="schema-website-org">'$(printf "%s" "$schema" | sed -e 's/[&/\]/\\&/g')'</script>#s' -i "$f"
  else
    perl -0777 -pe 's#</head>#<script type="application/ld+json" id="schema-website-org">'$(printf "%s" "$schema" | sed -e 's/[&/\]/\\&/g')'</script>\n</head>#s' -i "$f"
  fi
  echo "🔎 schema(WebSite+Org) -> $f"
done
echo "✅ WebSite SearchAction + Org schema ensured"
