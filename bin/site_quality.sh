#!/usr/bin/env bash
# Minimal quality checks for static HTML (no Node, no pip)
set -Eeuo pipefail; IFS=$'\n\t'

ERR=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

warn(){ printf '⚠️  %s\n' "$*"; }
fail(){ printf '❌ %s\n' "$*"; ERR=1; }

for f in "${FILES[@]}"; do
  # --- Warnings (won't fail the job) ---
  # nav CSS linked?
  grep -qi '<link[^>]*href="/assets/nav-fix\.css"' "$f" || warn "Missing nav-fix.css in $f"
  # skip link present?
  (grep -qi 'class="skip-to-content"' "$f" || grep -qi 'id="skip-to-content"' "$f") || warn "Missing skip link in $f"
  # main landmark id?
  grep -qi '<main[^>]*\bid="main"' "$f" || warn "Missing <main id=\"main\"> in $f"

  # --- Hard failures (really broken) ---
  # bogus preconnects like href="index.html:https://…"
  grep -qi 'href="[^"]\+://.*\.html:' "$f" && fail "Malformed preconnect href in $f"

  # JSON-LD printed as visible text (not inside a proper script)
  if grep -Pq '>\s*\{\s*"@context"\s*:\s*"https?://schema\.org"' "$f"; then
    grep -Pq '<script[^>]*type="application/ld\+json"[^>]*>\s*\{\s*"@context"\s*:\s*"https?://schema\.org"' "$f" \
      || fail "Raw JSON-LD visible (not wrapped) in $f"
  fi
done

echo "—— Summary ——"
echo "Files checked: ${#FILES[@]}"
exit $ERR
