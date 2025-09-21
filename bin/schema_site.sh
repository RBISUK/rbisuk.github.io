#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
HOME="index.html"
[[ -f "$HOME" ]] || exit 0
ts=$(date -u +%Y-%m-%d)

read -r -d '' SCHEMA <<JSON
<script type="application/ld+json">
{
 "@context":"https://schema.org",
 "@type":"Organization",
 "name":"RBIS",
 "url":"$ORIGIN",
 "logo":"$ORIGIN/assets/og/rbis-logo.png",
 "sameAs":[
   "https://www.linkedin.com/company/rbis-intelligence"
 ],
 "contactPoint":[{"@type":"ContactPoint","contactType":"sales","email":"info@rbisintelligence.com"}]
}
</script>
<script type="application/ld+json">
{
 "@context":"https://schema.org",
 "@type":"WebSite",
 "name":"RBIS",
 "url":"$ORIGIN"
}
</script>
JSON

grep -q 'schema.org' "$HOME" && exit 0
cp -p "$HOME" "$HOME.bak.$(date -u +%Y%m%dT%H%M%SZ)"
awk -v B="$SCHEMA" '/<\/head>/ && !done{ print B; print; done=1; next } { print }' "$HOME" > "$HOME.tmp" && mv "$HOME.tmp" "$HOME"
echo "✅ Organization + WebSite schema added to $HOME"
