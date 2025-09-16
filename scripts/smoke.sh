#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/smoke.sh                # auto-detect base
#   ./scripts/smoke.sh 3001           # force port
#   ./scripts/smoke.sh http://host:p  # force full base

force="${1:-}"

# --- Discover base URL ---
detect_base() {
  # If caller gave a full URL, use it
  if [[ "$force" =~ ^https?:// ]]; then
    echo "$force"; return 0
  fi
  # If caller gave just a port
  if [[ -n "$force" && "$force" =~ ^[0-9]+$ ]]; then
    echo "http://localhost:$force"; return 0
  fi

  # Try pm2 to find script args like "-p 3001"
  if command -v pm2 >/dev/null 2>&1; then
    args_line="$(pm2 info rbis-app 2>/dev/null | awk -F: '/script args/ {sub(/^[ \t]+/,"",$2); print $2}' || true)"
    if [[ "$args_line" =~ \-p[[:space:]]*([0-9]+) ]]; then
      echo "http://localhost:${BASH_REMATCH[1]}"; return 0
    fi
  fi

  # Try env var
  if [[ -n "${PORT:-}" ]]; then
    echo "http://localhost:$PORT"; return 0
  fi

  # Probe common ports
  for p in 3000 3001 3002 3003 3004 3005 3006 3007 3008 3009 3010; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$p/api/health" || true)
    if [[ "$code" == "200" ]]; then
      echo "http://localhost:$p"; return 0
    fi
  done

  # Fallback
  echo "http://localhost:3000"
}

base="$(detect_base)"
echo "🔎 Using base: $base"

pass=true

check() {
  url="$1"
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || true)
  if [[ "$code" =~ ^2|3 ]]; then
    printf "✅ %s -> %s\n" "$url" "$code"
  else
    printf "❌ %s -> %s\n" "$url" "$code"
    pass=false
  fi
}

# --- GET checks ---
check "$base/"
check "$base/legal"
check "$base/api/health"

# --- POST checks ---
intake_code=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","notes":"hello"}' \
  "$base/api/intake" || true)

# Richer payload for /api/lead to satisfy tighter validators
lead_payload='{
  "name":"Test User",
  "email":"test@example.com",
  "phone":"+447700900123",
  "source":"website",
  "campaign":"smoke",
  "channel":"organic",
  "utm":{"source":"dev","medium":"cli","campaign":"smoke"},
  "consent":{"contact":true,"store":true}
}'
lead_resp=$(mktemp)
lead_code=$(curl -s -D - -o "$lead_resp" -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d "$lead_payload" \
  "$base/api/lead" 2>/dev/null | head -n1 | awk '{print $2}' || true)

[[ "$intake_code" =~ ^2|3 ]] && echo "✅ /api/intake -> $intake_code" || { echo "❌ /api/intake -> $intake_code"; pass=false; }

if [[ "$lead_code" =~ ^2|3 ]]; then
  echo "✅ /api/lead -> $lead_code"
else
  echo "❌ /api/lead -> $lead_code"
  echo "——— /api/lead response body ———"
  cat "$lead_resp" || true
  echo
  pass=false
fi
rm -f "$lead_resp" || true

# Final status
$pass
