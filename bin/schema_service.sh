#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
f="products.html"; [[ -f "$f" ]] || exit 0
[[ $(grep -c 'schema.org/Service' "$f") -gt 0 ]] && exit 0
cat > .tmp.ld <<'JSON'
<script type="application/ld+json">
{
 "@context":"https://schema.org",
 "@type":"Service",
 "name":"RBIS Products & Services",
 "provider":{"@type":"Organization","name":"RBIS"},
 "areaServed":"GB",
 "serviceType":"Behavioural Intelligence"
}
</script>
JSON
awk '/<\/head>/ && !done { system("cat .tmp.ld"); print; done=1; next } {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
rm -f .tmp.ld
echo "✅ Service schema added to products.html"
