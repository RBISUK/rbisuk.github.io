#!/usr/bin/env bash
set -euo pipefail
PROD_URL="${PROD_URL:-https://hdr.rbisintelligence.com}"
PROD_PATH="${PROD_PATH:-/health}"
MAX_TRIES="${MAX_TRIES:-40}"
SLEEP_SECONDS="${SLEEP_SECONDS:-3}"
TARGET="${PROD_URL%/}${PROD_PATH}"
echo "==> Poll ${TARGET} for 200"
for i in $(seq 1 "$MAX_TRIES"); do
  CODE=$(curl -sSL -o /dev/null -A "RBIS-Smoke/1.0" -w "%{http_code}" "$TARGET")
  echo "try $i -> $CODE"
  [ "$CODE" = "200" ] && { echo "✅ Healthy"; exit 0; }
  sleep "$SLEEP_SECONDS"
done
echo "❌ ${TARGET} not healthy"
curl -sSL -D - -o /dev/null "$TARGET" || true
exit 1
