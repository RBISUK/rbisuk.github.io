#!/usr/bin/env bash
set -Eeuox pipefail
trap 'echo "💥 Error on line $LINENO: $BASH_COMMAND (exit $?)"' ERR

PORT=3045
LOG=/tmp/next.out
PID_FILE=/tmp/next.pid

cleanup() {
  echo "🧼 Stopping server..."
  if [[ -f "$PID_FILE" ]]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
    rm -f "$PID_FILE"
  fi
}
trap cleanup EXIT

echo "🔨 Building project..."
rm -rf .next
npm run build
echo "✅ Build succeeded"

echo "🚀 Starting server on port $PORT..."
pkill -f "next start" 2>/dev/null || true
for p in {3000..3060}; do (lsof -ti :$p | xargs -r kill -9) 2>/dev/null || true; done

NODE_ENV=production npx next start -p "$PORT" >"$LOG" 2>&1 & echo $! > "$PID_FILE"

echo -n "⏳ Waiting for http://localhost:$PORT ..."
for i in {1..60}; do
  if curl -sSf "http://localhost:$PORT/health.txt" >/dev/null || \
     curl -sSf "http://localhost:$PORT/" >/dev/null; then
    echo " up."
    break
  fi
  echo -n "."
  sleep 0.5
done
if ! curl -sSf "http://localhost:$PORT/" >/dev/null; then
  echo; echo "❌ Server never became ready. Last 80 log lines:"
  tail -n 80 "$LOG" || true
  exit 1
fi

echo "🌐 Checking key routes..."
FAIL=0
check () {
  local path="$1"
  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT$path")
  printf "%-16s %s\n" "$path" "$code"
  [[ "$code" == "200" ]] || FAIL=1
}

check /
check /solutions
check /veridex
check /pact-ledger
check /hdr
check /hdr/intake
check /contact
check /privacy
check /trust-centre
check /dashboard

if [[ $FAIL -eq 0 ]]; then
  echo "✅ All checks passed"
else
  echo "❌ Some routes failed"
  exit 1
fi
