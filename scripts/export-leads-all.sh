#!/usr/bin/env bash
set -euo pipefail

out="${1:-leads-all-$(date +%Y%m%d).csv}"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Concatenate current + archives (gz and plain)
# Order newest first by filename timestamp
{
  if compgen -G "logs/archive/leads-*.jsonl.gz" > /dev/null; then
    ls -1t logs/archive/leads-*.jsonl.gz | xargs -r -I{} sh -c 'gzip -dc "{}" || true'
  fi
  if compgen -G "logs/archive/leads-*.jsonl" > /dev/null; then
    ls -1t logs/archive/leads-*.jsonl | xargs -r -I{} sh -c 'cat "{}" || true'
  fi
  [[ -f logs/leads.jsonl ]] && cat logs/leads.jsonl || true
} > "$tmp"

# Reuse column set; flatten UTM/consent
cols='[
 "id","receivedAt","name","email","phone",
 "source","campaign","channel",
 "tenantId","module","leadType",
 "utm.source","utm.medium","utm.campaign","utm.term","utm.content",
 "consent.contact","consent.store"
]'

# If empty, just create a header
if [[ ! -s "$tmp" ]]; then
  jq -r --argjson C "$cols" '($C | join(","))' <<< 'null' > "$out"
  echo "✅ No leads found; wrote header to $out"
  exit 0
fi

# Convert JSONL→CSV with stable header
{
  jq -r --argjson C "$cols" '
    ($C | join(",")),
    (inputs
     | def g($p): reduce ($p|split(".")[]) as $k (.; if type=="object" and has($k) then .[$k] else null end);
     $C as $h
     | ($h | map( (g(.)) // "" ) )
     | @csv
    )
  ' <(sed -n '1p' "$tmp") <(tail -n +1 "$tmp")
} > "$out"

echo "✅ Exported CSV (archives + current) -> $out"
