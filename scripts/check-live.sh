#!/usr/bin/env bash
set -euo pipefail

HOST="https://www.rbisintelligence.com"

echo "🔍 Checking production… $HOST"

# 1) Routes
for p in / /main /hdr; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$HOST$p")
  echo "$p → $code"
  if [[ "$code" -ne 200 ]]; then
    echo "❌ FAIL on $p"
    exit 1
  fi
done

# 2) CSS presence
css_url=$(curl -s "$HOST" | grep -o 'href="[^"]*\.css"' | head -n1 | cut -d'"' -f2)
if [[ -z "$css_url" ]]; then
  echo "❌ No CSS file linked"
  exit 1
fi
bytes=$(curl -s "$HOST$css_url" | wc -c)
echo "CSS bytes: $bytes"
if [[ "$bytes" -lt 50000 ]]; then
  echo "❌ CSS too small — likely missing Tailwind"
  exit 1
fi

# 3) Hero text sanity check
curl -s "$HOST/main" | grep -q "RBIS" && echo "✅ Hero text present" || echo "❌ Hero text missing"
