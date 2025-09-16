#!/usr/bin/env bash
set -euo pipefail

HOST="https://www.rbisintelligence.com"
ROUTES="/ /main /hdr /hdr/pricing /hdr/what-it-does /hdr/value /robots.txt /sitemap.xml"

echo "1) Poll prod until main page returns 200..."
for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$HOST/")
  if [ "$code" = "200" ]; then echo "main: 200"; break; fi
  sleep 2
done

echo "2) Smoke check key routes..."
for p in $ROUTES; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$HOST$p")
  echo "$p -> $code"
done

echo "3) Ensure CSS is loading..."
bytes=$(curl -s "$HOST" | grep -o '<link[^>]*stylesheet[^>]*>' | head -n1 | xargs curl -s | wc -c)
echo "CSS bytes: $bytes"
if [ "$bytes" -lt 50000 ]; then echo "❌ CSS too small, styles missing"; exit 1; fi

echo "✅ All good: styles + routes healthy"
