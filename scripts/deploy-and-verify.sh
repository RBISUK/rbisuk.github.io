#!/usr/bin/env bash
set -euo pipefail

# ---- Config ----
PROJECT="rbisuk-github-io"                        # your Vercel project (already linked)
HOST="${HOST:-https://www.rbisintelligence.com}"  # prod hostname (can override: HOST=... ./script)
PRIMARY="/main"                                   # key route to verify first
ROUTES=("/" "/main" "/hdr" "/hdr/pricing" "/hdr/what-it-does" "/main/value")
POLL_MAX=36           # 36 * 10s = 6 minutes
SLEEP_SECS=10

say(){ printf "\n\033[1;36m%s\033[0m\n" "$*"; }
fail(){ echo -e "\n\033[1;31m✗ $*\033[0m"; exit 1; }
ok(){ echo -e "\033[1;32m✓ $*\033[0m"; }

# ---- Pre-flight: local sanity (optional but helpful) ----
say "Local build sanity"
rm -rf .next >/dev/null 2>&1 || true
npm ci >/dev/null
npm run -s build >/dev/null
ok "Local build ok"

# ---- Force a prod deployment via Git push (triggers Vercel Git integration) ----
BUMP=".vercel-bump"
echo "v=$(date +%s)" > "$BUMP"
git add "$BUMP"
git commit -m "chore: deploy bump $(date -u +%FT%TZ)" >/dev/null || true
git push -q || fail "Git push failed"
ok "Pushed deploy bump"

# ---- Optional: show most recent Vercel deployments ----
if command -v vercel >/dev/null 2>&1; then
  say "Recent Vercel deploys (last 5)"
  vercel ls "$PROJECT" --limit=5 || true
else
  say "Vercel CLI not found; skipping deploy list"
fi

# ---- Poll production until the new HTML is live ----
# We treat the old stub as invalid if it contains this text:
STUB_PHRASE="Home for RBIS content."

say "Polling production for fresh HTML @ $HOST$PRIMARY"
i=0
while (( i < POLL_MAX )); do
  code=$(curl -s -o /tmp/_page.html -w "%{http_code}" "$HOST$PRIMARY?v=$(date +%s)")
  if [[ "$code" == "200" ]]; then
    if ! grep -q "$STUB_PHRASE" /tmp/_page.html; then
      ok "Primary route looks fresh (no stub text)."
      break
    fi
  fi
  ((i++))
  echo "…waiting ($i/$POLL_MAX) — code=$code"
  sleep "$SLEEP_SECS"
done
(( i < POLL_MAX )) || fail "Timed out waiting for fresh HTML on $PRIMARY"

# ---- Quick CSS presence check on PROD (avoid white page due to missing CSS) ----
say "Checking linked CSS assets on $PRIMARY"
# extract stylesheet hrefs, fetch one and ensure body > 0 bytes
hrefs=$(grep -oE '<link[^>]+rel="stylesheet"[^>]+href="[^"]+' /tmp/_page.html | sed -E 's/.*href="//')
if [[ -z "$hrefs" ]]; then
  fail "No CSS <link> tags found on $PRIMARY"
fi

one_css=$(echo "$hrefs" | head -n1)
case "$one_css" in
  http*) css_url="$one_css" ;;
  /*)    css_url="$HOST$one_css" ;;
  *)     css_url="$HOST/$one_css" ;;
esac

bytes=$(curl -sL "$css_url" | wc -c | awk '{print $1}')
[[ "$bytes" -gt 100 ]] || fail "CSS asset seems empty ($bytes bytes): $css_url"
ok "CSS loaded ($bytes bytes) — $css_url"

# ---- Smoke remaining key routes ----
say "Route smoke"
for p in "${ROUTES[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$HOST$p?v=$(date +%s)")
  printf "%-18s -> %s\n" "$p" "$code"
  [[ "$code" -lt 400 ]] || fail "$p returned $code"
done
ok "All routes healthy"

say "DONE 🚀  Production looks good at $HOST"
