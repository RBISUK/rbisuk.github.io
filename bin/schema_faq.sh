#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  grep -q '<summary>' "$f" || continue
  mapfile -t blocks < <(perl -0777 -ne 'while (m|<details>(.*?)</details>|sg){print "$1\n---\n"}' "$f")
  declare -a items=(); count=0
  for b in "${blocks[@]}"; do
    q=$(sed -n 's/.*<summary>\(.*\)<\/summary>.*/\1/p' <<<"$b")
    a=$(sed -n 's/.*<\/summary>\(.*\)$/\1/p' <<<"$b" | sed 's/<[^>]*>//g' | tr -s " " " " | sed 's/^ *//;s/ *$//')
    [[ -z "$q" || -z "$a" ]] && continue
    count=$((count+1))
    items+=("{\"@type\":\"Question\",\"name\":\"$q\",\"acceptedAnswer\":{\"@type\":\"Answer\",\"text\":\"$a\"}}")
  done
  [[ $count -eq 0 ]] && continue
  SCHEMA=$(cat <<JSON
<script id="rbis-faq" type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[${items[*]}]}
</script>
JSON
)
  awk -v B="$SCHEMA" '
    BEGIN{done=0;skip=0}
    /<script id="rbis-faq"/{ if(!done){print B; done=1}; skip=1 }
    skip && /<\/script>/ { skip=0; next }
    /<\/head>/ && !done { print B; print; done=1; next }
    { if(!skip) print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ FAQ schema -> $f ($count Q/A)"
done
