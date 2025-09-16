#!/usr/bin/env bash
set -euo pipefail

say(){ printf "\n\033[1;36m%s\033[0m\n" "$*"; }
URL="${URL:-https://rbisuk.vercel.app}"   # override: URL=https://rbisintelligence.com ./audit.sh
PORT="${PORT:-3007}"

say "▶ Project shape"
tree -L 2 app || echo "tree not installed, skipping"

say "▶ Local build & start"
rm -rf .next
npm ci
npm run build
npm run start -s -- -p "$PORT" & PID=$!
sleep 3
for p in / /main /hdr; do
  printf "%-18s -> " "$p"
  curl -s -o /dev/null -w "%{http_code}\n" "http://127.0.0.1:$PORT$p"
done
kill $PID || true

say "▶ Live check: $URL"
for p in / /main /hdr; do
  printf "%-18s -> " "$p"
  curl -s -o /dev/null -w "%{http_code}\n" "$URL$p"
done

say "✅ Audit done"
