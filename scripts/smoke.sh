#!/usr/bin/env bash
set -euo pipefail

PORT=${PORT:-3001}            # avoid 3000 in Codespaces
export PORT
echo "[smoke] Using PORT=$PORT"

# kill any stale server on this port
lsof -ti:$PORT | xargs -r kill -9 || true
pkill -f "next dev -p $PORT" 2>/dev/null || true

echo "[smoke] Typecheck…"
npm run -s typecheck

echo "[smoke] Build…"
npm run -s build

echo "[smoke] Start dev in background…"
( npm run -s dev:port >/tmp/next-dev.log 2>&1 ) &

# wait for server
echo -n "[smoke] Waiting for server"; tries=0
until curl -sSf "http://127.0.0.1:$PORT" >/dev/null 2>&1; do
  sleep 0.7; tries=$((tries+1)); echo -n "."
  if [ $tries -gt 60 ]; then
    echo; echo "[smoke] Server failed to start:"
    tail -n +1 /tmp/next-dev.log || true
    exit 1
  fi
done
echo; echo "[smoke] Server up."

fail=0
check() {
  local path="$1"; shift
  local expect="$1"; shift
  echo "[smoke] GET $path expects: $expect"
  body=$(curl -fsS "http://127.0.0.1:$PORT$path")
  echo "$body" | grep -qi "$expect" || { echo "[FAIL] $path missing '$expect'"; fail=1; }
}

# Routes to validate
check "/"          "RBIS — Main"     # root redirects to /main and renders RBIS title
check "/main"      "RBIS — Main"
check "/hdr"       "HDR Funnel"

# Optional: add more when subpages exist
# check "/hdr/pricing" "Pricing"
# check "/main/value" "Value"

# Tailwind sanity: look for a common class you use (adjust to real class if you want)
echo "[smoke] Tailwind sanity (presence of 'class=')"
curl -fsS "http://127.0.0.1:$PORT/main" | grep -q 'class=' || { echo "[WARN] Could not detect classes on /main"; }

# Cleanup: kill the dev server
pkill -f "next dev -p $PORT" 2>/dev/null || true

if [ $fail -ne 0 ]; then
  echo "[smoke] FAIL"
  exit 1
fi
echo "[smoke] PASS"
