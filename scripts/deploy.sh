#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
BRANCH="${BRANCH:-main}"
MSG="${MSG:-deploy: production update}"
RUN_TESTS="${RUN_TESTS:-1}"   # set RUN_TESTS=0 to skip smoke/Playwright

say() { printf "\n\033[1;36m%s\033[0m\n" "$*"; }
err() { printf "\n\033[1;31mERROR:\033[0m %s\n" "$*" >&2; exit 1; }

# --- Basics ---
say "1) Git status / branch"
git rev-parse --abbrev-ref HEAD
git status --short || true

# --- Install deps if needed ---
if [ ! -d node_modules ]; then
  say "2) Installing dependencies (npm ci)…"
  npm ci || npm install
else
  say "2) Using existing node_modules"
fi

# --- Build (prints route table) ---
say "3) Building Next.js (npx next build)…"
BUILD_OUT="$(npx next build 2>&1 | tee /dev/stdout)"
echo "$BUILD_OUT" | grep -E 'Route \(app\)|^┌|^├|^└|/_not-found|/api/' || true

# --- Show your source tree for sanity (HDR/RBIS split) ---
say "4) Showing app/ tree (HDR & RBIS present?)"
if command -v tree >/dev/null 2>&1; then
  tree -L 3 app || true
else
  ls -R app || true
fi

# --- Optional tests ---
if [ "$RUN_TESTS" = "1" ]; then
  say "5) Running smoke"
  if npm run | grep -q "^  smoke"; then
    PORT=3001 npm run smoke
  else
    say "   (no smoke script found, skipping)"
  fi

  say "6) Running Playwright e2e + API tests"
  if [ -f "playwright.config.ts" ] || [ -f "playwright.config.mjs" ] || [ -f "playwright.config.js" ]; then
    npx playwright install --with-deps
    PORT=3100 npx playwright test
  else
    say "   (no Playwright config found, skipping)"
  fi
else
  say "5) Tests skipped (RUN_TESTS=0)"
fi

# --- Commit & push (triggers Vercel) ---
say "7) Commit & push → GitHub (Vercel will auto-deploy)"
git add -A
if git diff --cached --quiet; then
  say "   No changes staged. Creating an empty commit to trigger deploy."
  git commit --allow-empty -m "$MSG"
else
  git commit -m "$MSG"
fi
git push origin "$(git rev-parse --abbrev-ref HEAD)"

# --- Helpful links ---
say "8) Done. Check:"
ORIGIN_URL="$(git remote get-url origin 2>/dev/null || echo 'https://github.com/<user>/<repo>')"
REPO_WEB="$(echo "$ORIGIN_URL" | sed -E 's#(git@github.com:|https://github.com/)([^/]+/[^.]+)(\.git)?#https://github.com/\2#')"
echo "GitHub commits:   $REPO_WEB/commits/$BRANCH"
echo "Vercel dashboard: https://vercel.com/dashboard (project: rbisuk-github-io)"
echo
echo "Tip: to deploy without tests -> RUN_TESTS=0 MSG='deploy: quick push' bash scripts/deploy.sh"
