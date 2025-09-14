#!/usr/bin/env bash
# RBIS bootstrap — clean boot, strict mode, health + smoke checks
set -euo pipefail

ROOT="/workspaces/rbisuk.github.io"
cd "$ROOT"

echo "[RBIS] Using Node:"
if command -v nvm >/dev/null 2>&1; then
  nvm install 18 >/dev/null || true
  nvm use 18 >/dev/null || true
fi
node -v || true
npm -v || true

# Ensure required dirs exist
mkdir -p app/api/health app/api/submit app/form app/thank-you lib logs scripts

# Install deps if missing
if [ ! -d node_modules ]; then
  echo "[RBIS] Installing dependencies…"
  npm install
fi

# Start dev in background if not running
if ! curl -fsS http://127.0.0.1:3000/api/health >/dev/null 2>&1; then
  echo "[RBIS] Starting dev server…"
  pkill -f "next dev" >/dev/null 2>&1 || true
  HOST=127.0.0.1 PORT=3000 npm run dev > logs/dev.log 2>&1 &
  sleep 3
fi

# Health check (up to 30s)
echo "[RBIS] Waiting for health…"
ok=""
for i in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:3000/api/health >/dev/null 2>&1; then ok="yes"; break; fi
  sleep 1
done
if [ -z "$ok" ]; then
  echo "[RBIS] ❌ Dev not healthy. Tail dev log:"; tail -n 100 logs/dev.log || true; exit 1
fi
echo "[RBIS] ✅ Health OK"

echo "[RBIS] Bootstrap finished."
