#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
# Usage: bash bin/meta_verify.sh google=TOKEN bing=TOKEN yandex=TOKEN pinterest=TOKEN ahrefs=TOKEN
declare -A META=( [google]=google-site-verification [bing]=msvalidate.01 [yandex]=yandex-verification [pinterest]=p:domain_verify [ahrefs]=ahrefs-site-verification )
for pair in "$@"; do
  k="${pair%%=*}"; v="${pair#*=}"
  [[ -n "${META[$k]:-}" && -n "$v" ]] || continue
  name="${META[$k]}"
  for f in $(git ls-files '*.html'); do
    if rg -q "name=\"${name}\"" "$f"; then
      perl -0777 -pe "s#<meta\\s+name=\"${name}\"\\s+content=\"[^\"]*\"\\s*/?>#<meta name=\"${name}\" content=\"${v}\">#i" -i "$f"
    else
      perl -0777 -pe "s#</head>#<meta name=\"${name}\" content=\"${v}\">\n</head>#i" -i "$f"
    fi
  done
  echo "✅ injected $name"
done
[[ $# -eq 0 ]] && echo "ℹ️ pass tokens like: google=XXXX bing=YYYY"
