#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
ORIGIN="${SITE_ORIGIN:-https://www.rbisintelligence.com}"
cap(){ local s="${1:-}"; printf '%s' "$s" | awk -F'-' '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } print}' | sed 's/&/ & /g;s/  */ /g'; }
title_for(){ sed -n 's:.*<title[^>]*>\(.*\)</title>.*:\1:pI' "$1" | head -n1 | sed 's/ •.*$//' ; }
for f in $(git ls-files '*.html' | sort); do
  [[ "$f" == "index.html" ]] && continue
  url="$ORIGIN/${f}"
  path="${f%/*}"
  pos=1; crumbs=()
  crumbs+=( "{\"@type\":\"ListItem\",\"position\":$((pos++)),\"name\":\"Home\",\"item\":\"$ORIGIN/\"}" )
  if [[ "$path" != "$f" && "$path" != "." ]]; then
    IFS='/' read -r -a segs <<<"$path"; build=""
    for s in "${segs[@]}"; do
      build="${build:+$build/}$s"
      name="$(cap "${s//_/ }")"
      crumbs+=( "{\"@type\":\"ListItem\",\"position\":$((pos++)),\"name\":\"$name\",\"item\":\"$ORIGIN/$build/\"}" )
    done
  fi
  leaf="$(title_for "$f")"; [[ -z "$leaf" ]] && leaf="$(cap "$(basename "$f" .html | sed 's/-/ /g')")"
  crumbs+=( "{\"@type\":\"ListItem\",\"position\":$((pos++)),\"name\":\"$leaf\",\"item\":\"$url\"}" )
  SCHEMA=$(cat <<JSON
<script id="rbis-bc" type="application/ld+json">
{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[${crumbs[*]}]}
</script>
JSON
)
  awk -v B="$SCHEMA" '
    BEGIN{done=0;skip=0}
    /<script id="rbis-bc"/{ if(!done){print B; done=1}; skip=1 }
    skip && /<\/script>/ { skip=0; next }
    /<\/head>/ && !done { print B; print; done=1; next }
    { if(!skip) print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "✅ breadcrumbs -> $f"
done
