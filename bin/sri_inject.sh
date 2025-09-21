#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
need(){ command -v "$1" >/dev/null; }
need curl || { echo "ℹ️ curl missing"; exit 0; }
need openssl || { echo "ℹ️ openssl missing"; exit 0; }

sri(){
  local url="$1"
  local body h
  body="$(curl -fsSL "$url" || true)" || return 1
  [[ -z "$body" ]] && return 1
  h="$(printf '%s' "$body" | openssl dgst -sha384 -binary | openssl base64 -A)"
  printf 'sha384-%s' "$h"
}

changed=0
for f in $(git ls-files '*.html'); do
  tmp="$f.tmp"; cp "$f" "$tmp"
  # scripts
  while read -r tag url; do
    [[ -z "$url" ]] && continue
    [[ "$url" != https://* ]] && continue
    # skip known unversioned dynamic CDN
    [[ "$url" == *"cdn.tailwindcss.com"* ]] && continue
    rg -q 'integrity=' <<<"$tag" && continue
    # require versiony hint in URL to be stable
    [[ "$url" =~ (\?v=|@|/v[0-9]|/[0-9]{2,}(\.|/)) ]] || continue
    hash="$(sri "$url" || true)"
    [[ -z "$hash" ]] && continue
    perl -0777 -pe "s#<script([^>]*?)src=\"$url\"([^>]*)>#<script\1src=\"$url\" integrity=\"$hash\" crossorigin=\"anonymous\"\2>#g" -i "$tmp"
    changed=1
  done < <(rg -No '<script[^>]+src="([^"]+)"[^>]*>' "$f" | awk -F'"' '{print $0" "$2}')
  # stylesheets
  while read -r tag url; do
    [[ "$url" != https://* ]] && continue
    rg -q 'integrity=' <<<"$tag" && continue
    [[ "$url" =~ (\?v=|@|/v[0-9]|/[0-9]{2,}(\.|/)) ]] || continue
    hash="$(sri "$url" || true)"
    [[ -z "$hash" ]] && continue
    perl -0777 -pe "s#<link([^>]*?)href=\"$url\"([^>]*rel=\"stylesheet\"[^>]*)>#<link\1href=\"$url\" integrity=\"$hash\" crossorigin=\"anonymous\"\2>#g" -i "$tmp"
    changed=1
  done < <(rg -No '<link[^>]+rel="stylesheet"[^>]+href="([^"]+)"[^>]*>' "$f" | awk -F'"' '{print $0" "$2}')
  if ! diff -q "$f" "$tmp" >/dev/null; then mv "$tmp" "$f"; else rm -f "$tmp"; fi
done
[[ $changed -eq 1 ]] && echo "✅ SRI injected where safe" || echo "ℹ️ SRI: no eligible tags"
