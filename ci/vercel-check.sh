#!/usr/bin/env bash
set -euo pipefail

PORT=3045
LOG=/tmp/next.out

echo "🔨 Building project..."
rm -rf .next
if ! npm run build; then
  echo "❌ Build failed"
  exit 1
fi
echo "✅ Build succeeded"

echo "🚀 Starting server on port $PORT..."
pkill -f "next start" 2>/dev/null || true
for p in {3000..3060}; do (lsof -ti :$p | xargs -r kill -9) 2>/dev/null || true; done

NODE_ENV=production next start -p $PORT >"$LOG" 2>&1 &
PID=$!
sleep 5

cleanup() {
  kill "$PID" 2>/dev/null || true
}
trap cleanup EXIT

echo "🌐 Checking key routes..."
ROUTES=(
  /
  /solutions
  /veridex
  /pact-ledger
  /hdr
  /hdr/intake
  /contact
  /privacy
  /trust-centre
  /dashboard
)
FAIL=0
for r in "${ROUTES[@]}"; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT$r")
  if [ "$CODE" != "200" ]; then
    echo "❌ $r returned $CODE"
    FAIL=1
  else
    echo "✅ $r"
  fi
done

echo "🔒 Checking headers..."
curl -sI "http://localhost:$PORT/" | grep -E "Strict-Transport-Security|X-Frame-Options|X-Content-Type-Options|Referrer-Policy|Permissions-Policy" || {
  echo "❌ Missing expected security headers"
  FAIL=1
}

if command -v npx >/dev/null && [ -f tsconfig.e2e.json ]; then
  echo "🧪 Running Playwright tests..."
  if ! BASE_URL="http://localhost:$PORT" npx playwright test -c tsconfig.e2e.json; then
    echo "❌ Playwright tests failed"
    FAIL=1
  else
    echo "✅ Playwright tests passed"
  fi
fi

if [ "$FAIL" -eq 0 ]; then
  echo "🎉 All checks passed. Build is production-ready."
else
  echo "🚨 One or more checks failed. See logs above."
  exit 1
fi


