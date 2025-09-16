#!/usr/bin/env bash
set -euo pipefail
file="logs/leads.jsonl"
[[ -f "$file" ]] || { echo "No file: $file"; exit 1; }
tail -f "$file" | jq -r '
  .receivedAt+" | "+(.name//"")+" | "+(.email//"")+" | "+(.phone//"")+" | "+(.source//"")+"/"+(.campaign//"")'
