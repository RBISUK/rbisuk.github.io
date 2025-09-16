#!/usr/bin/env bash
set -euo pipefail

input="logs/leads.jsonl"
out="${1:-leads-$(date +%Y%m%d).csv}"

if ! command -v jq >/dev/null 2>&1; then
  echo "❌ jq not found. Install jq to export CSV." >&2
  exit 1
fi
if [[ ! -f "$input" ]]; then
  echo "❌ No leads file at $input" >&2
  exit 1
fi

# Columns we care about (adjust if you add more fields)
cols='[
 "id","receivedAt","name","email","phone",
 "source","campaign","channel",
 "tenantId","module","leadType",
 "utm.source","utm.medium","utm.campaign","utm.term","utm.content",
 "consent.contact","consent.store"
]'

# Read JSONL -> CSV with stable header
{
  jq -r --argjson C "$cols" '
    # print header
    ($C | join(",")),
    # read each line independently
    (inputs
     | def g($p): reduce ($p|split(".")[]) as $k (.; if type=="object" and has($k) then .[$k] else null end);
     $C as $h
     | ($h | map( (g(.)) // "" ) )
     | @csv
    )
  ' <(sed -n '1p' "$input") <(tail -n +1 "$input")
} > "$out"

echo "✅ Exported CSV -> $out"
