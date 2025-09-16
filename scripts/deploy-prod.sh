#!/usr/bin/env bash
set -euo pipefail

say(){ printf "\n\033[1;36m%s\033[0m\n" "$*"; }

say "1) Stage & commit"
git add .
git commit -m "deploy: production build with cube + Sentry + Tailwind fix" || echo "nothing to commit"

say "2) Push to GitHub (Vercel auto-deploys)"
git push origin main

say "3) Poll production until HTML + CSS are healthy"
HOST="https://www.rbisintelligence.com"
ROUTES="/ /main /hdr /hdr/pricing /hdr/what-it-does /main/value /robots.txt /sitemap.xml"

for p in $ROUTES; do
  printf "%-20s -> " "$p"
  code=$(curl -s -o /dev/null -w "%{http_code}" "$HOST$p")
  echo "$code"
  if [ "$code" -ge 400 ]; then
    echo "❌ FAIL on $p"
    exit 1
  fi
done

say "✅ Production live + healthy"
