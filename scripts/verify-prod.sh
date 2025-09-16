#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-https://www.rbisintelligence.com}"
ROUTES="/ /main /hdr /hdr/pricing /hdr/what-it-does /hdr/value /robots.txt /sitemap.xml"

echo "==> Poll production until /main returns 200"
for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$HOST/main")
  echo "try $i -> $code"
  [[ "$code" == "200" ]] && break
  sleep 2
done
[[ "$code" == "200" ]] || { echo "❌ main didn’t return 200"; exit 1; }

echo "==> Smoke check routes"
fail=0
for p in $ROUTES; do
  c=$(curl -s -o /dev/null -w "%{http_code}" "$HOST$p")
  echo "$p -> $c"
  [[ "$c" -ge 400 ]] && fail=1
done
[[ "$fail" == 0 ]] || { echo "❌ Some routes failed"; exit 1; }

echo "==> CSS presence"
html=$(curl -s "$HOST/main")
href=$(echo "$html" | grep -oE 'href="[^"]+\.css"' | head -1 | cut -d\" -f2)
[[ -n "$href" ]] || { echo "❌ No CSS <link> found"; exit 1; }

css_url="$HOST$href"
bytes=$(curl -s "$css_url" | wc -c)
echo "CSS bytes: $bytes"
[[ "$bytes" -gt 20000 ]] || { echo "❌ CSS too small"; exit 1; }

echo "✅ Production looks good"
