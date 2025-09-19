#!/usr/bin/env bash
set -Eeuox pipefail

PORT="${PORT:-3045}"
PID_FILE="/tmp/next.pid"

fail(){ echo "❌ $*" >&2; exit 1; }
cleanup(){
  echo "🧼 Stopping server..."
  [[ -f "$PID_FILE" ]] && kill "$(cat "$PID_FILE")" || true
  rm -f "$PID_FILE"
}
trap 'echo "💥 Error on line $LINENO: $BASH_COMMAND (exit $?)"; cleanup' ERR
trap cleanup EXIT

echo "🔨 Fresh build..."
rm -rf .next
npm run build >/dev/null 2>&1 || fail "Build failed"

echo "🚀 Starting Next on :$PORT"
# free the port if needed
pkill -f "next start -p $PORT" || true
NODE_ENV=production npx next start -p "$PORT" > /tmp/next.out 2>&1 &
echo $! > "$PID_FILE"

# wait for server
echo -n "⏳ Waiting for http://localhost:$PORT ..."
for i in {1..60}; do
  if curl -sf "http://localhost:$PORT/" >/dev/null; then echo " up."; break; fi
  sleep 0.5
  [[ $i -eq 60 ]] && fail "Server didn't start"
done

echo "🌐 Checking core routes..."
check(){
  local path="$1"
  local want="${2:-200}"
  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT$path")
  printf '%-18s %s\n' "$path" "$code"
  [[ "$code" == "$want" ]] || fail "Expected $want for $path, got $code"
}

# pages
check "/"
check "/solutions"
check "/veridex"
check "/pact-ledger"
check "/hdr"
check "/hdr/intake"
check "/contact"
check "/privacy"
check "/trust-centre"
check "/dashboard"
check "/api/dashboard"

echo "🔎 Verifying HDR CTA → /hdr/intake"
grep -RIn --line-number -E 'href=["'\'']/?hdr/intake/?["'\'']' pages || fail "HDR CTA to /hdr/intake not found in /pages"

echo "📄 Verifying demo PDFs are served"
PDFS=(
  "RBIS_DemoReports_Master_Index.pdf"
  "RBIS_Demo_Report_Harper_Ombudsman.pdf"
  "RBIS_Demo_Report_Northbank_Stage1.pdf"
  "RBIS_Demo_Report_Northbank.pdf"
  "RBIS_Demo_Report_Riverbank_RootCause.pdf"
  "RBIS_Demo_Report_Southmere_Stage2.pdf"
)
for f in "${PDFS[@]}"; do
  # Expect these under /public/reports/<file>
  if [[ ! -f "public/reports/$f" ]]; then
    echo "⚠️  Missing file: public/reports/$f (add it to make this URL work: /reports/$f)"
  fi
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT/reports/$f")
  if [[ "$code" != "200" ]]; then
    echo "⚠️  /reports/$f → $code (will be 200 after the file is placed in public/reports/)"
  else
    echo "✅ /reports/$f is accessible"
  fi
done

echo "🔐 Spot-check security headers"
hdr(){
  curl -sI "http://localhost:$PORT$1" | tr -d '\r' | grep -E "^(strict-transport-security|x-content-type-options|referrer-policy|permissions-policy|x-frame-options):" -i || true
}
hdr "/"

echo "✅ All checks completed"
