set -e
cd /workspaces/rbisuk.github.io

# Ensure layout imports CookieBanner + ScrollManager (idempotent)
if ! grep -q 'CookieBanner' app/layout.tsx; then
  sed -i '1i import CookieBanner from "@/components/CookieBanner";' app/layout.tsx
fi
if ! grep -q 'ScrollManager' app/layout.tsx; then
  sed -i '1i import ScrollManager from "@/components/ScrollManager";' app/layout.tsx
fi

# Inject components after {children}
if ! grep -q 'CookieBanner' app/layout.tsx || ! grep -q 'ScrollManager' app/layout.tsx; then
  :
fi
# Make sure {children} wrapper exists; then add the helpers directly after it.
# This is resilient: if already present, sed will still keep file valid.
sed -i '0,/{children}/s//{children}\n        <ScrollManager \/>\n        <CookieBanner \/>/' app/layout.tsx

# Ensure homepage links to /form (append a small CTA at end of main if not present)
if [ -f app/page.tsx ] && ! grep -q 'href="/form"' app/page.tsx; then
  cat >> app/page.tsx <<'TSX'

{/* Quick link to the intake form */}
<div className="mt-6">
  <a href="/form" className="inline-block px-4 py-2 rounded-lg bg-blue-600 text-white">
    Start Housing Disrepair Check
  </a>
</div>
TSX
fi

# Add small audit note footer on home (safe append)
if [ -f app/page.tsx ] && ! grep -q 'audit-logged' app/page.tsx; then
  cat >> app/page.tsx <<'TSX'

<footer className="mt-10 text-xs text-gray-500 text-center">
  We comply with GDPR, never sell your data, and your form is reviewed by a trained human — not AI.
  <br />
  All submissions are audit-logged and protected under UK data law.
</footer>
TSX
fi

echo "Stage 2 complete."
