#!/usr/bin/env bash
set -euo pipefail

PROD_URL="${PROD_URL:-https://rbisuk.github.io}"
PROD_PATH="${PROD_PATH:-/health}"
MAX_TRIES="${MAX_TRIES:-40}"
SLEEP_SECONDS="${SLEEP_SECONDS:-3}"

TARGET="${PROD_URL%/}${PROD_PATH}"

echo "==> Poll production until ${TARGET} returns 200 (following redirects)"
for i in $(seq 1 "$MAX_TRIES"); do
  CODE=$(curl -sSL -o /dev/null -A "RBIS-Smoke/1.0" -w "%{http_code}" "$TARGET")
  echo "try $i -> $CODE"
  if [ "$CODE" = "200" ]; then
    echo "✅ Healthy"
    exit 0
  fi
  sleep "$SLEEP_SECONDS"
done

echo "❌ ${TARGET} didn't return 200"
echo "---- headers ----"
curl -sSL -D - -o /dev/null -A "RBIS-Smoke/1.0" "$TARGET" || true
exit 1
