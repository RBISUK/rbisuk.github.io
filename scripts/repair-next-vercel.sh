#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar || true

info(){ printf "\033[1;34m[info]\033[0m %s\n" "$*"; }
ok(){ printf "\033[1;32m[ok]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err(){ printf "\033[1;31m[err]\033[0m %s\n" "$*"; }

# 0) Detect Next app root (repo root or a single subdir)
ROOT="."
if [[ ! -f next.config.js || ! -f package.json ]]; then
  CANDIDATES=($(find . -maxdepth 2 -type f -name "next.config.js" -printf '%h\n' | sort -u))
  if [[ ${#CANDIDATES[@]} -eq 1 ]]; then
    ROOT="${CANDIDATES[0]}"
    info "Detected Next.js app in subdir: $ROOT"
    cd "$ROOT"
  else
    warn "Could not uniquely detect Next.js app root. If your app is in a subfolder, set Vercel → Settings → Root Directory to that folder."
  fi
fi

# 1) Standardize on npm
info "Standardizing on npm…"
rm -f pnpm-lock.yaml yarn.lock
rm -rf node_modules

# 2) Remove Vercel overrides and ignore the runtime folder
info "Removing repo-level overrides…"
rm -f vercel.json || true
rm -rf .vercel || true
grep -qxF ".vercel" .gitignore || echo ".vercel" >> .gitignore

# 3) Ensure package.json uses Next defaults
info "Ensuring package.json scripts use Next defaults…"
node - <<'NODE'
const fs=require('fs');const p='package.json';
const j=JSON.parse(fs.readFileSync(p,'utf8'));
j.scripts=j.scripts||{};
j.scripts.build='next build';
j.scripts.dev=j.scripts.dev||'next dev';
j.scripts.start=j.scripts.start||'next start';
fs.writeFileSync(p, JSON.stringify(j,null,2));
NODE
ok "Scripts set (build/dev/start)."

# 4) Remove static export if present (breaks Vercel Next runtime)
info "Removing output: 'export' from next.config.js if present…"
if [[ -f next.config.js ]]; then
  sed -i "/output:[[:space:]]*['\"]export['\"]/d" next.config.js || true
fi

# 5) Kill unsupported Sentry option everywhere (v8 SDK)
info "Deleting unsupported Sentry 'enableLogs' lines…"
sed -i '/enableLogs[[:space:]]*:/d' **/*.ts **/*.tsx 2>/dev/null || true

# 6) Ensure minimal App Router exists so Next can compile
info "Ensuring minimal App Router files exist…"
mkdir -p app
if [[ ! -f app/layout.tsx ]]; then
cat > app/layout.tsx <<'TSX'
export const metadata = { title: "RBIS" };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
TSX
  ok "Created app/layout.tsx"
fi
if [[ ! -f app/page.tsx ]]; then
cat > app/page.tsx <<'TSX'
export default function Home() {
  return <main style={{padding: 24}}>RBIS is alive 🚀</main>;
}
TSX
  ok "Created app/page.tsx"
fi

# 7) Fail fast if merge-conflict markers remain
info "Checking for merge-conflict markers…"
if grep -R -nE '<<<<<<<|>>>>>>>' -- . >/dev/null; then
  err "Conflict markers found. Resolve these before building:"; grep -R -nE '<<<<<<<|>>>>>>>' -- .; exit 1
fi

# 8) Install & build locally
info "Installing deps with npm ci…"
npm ci

info "Building Next.js…"
npm run build

# 9) Emulate Vercel builder locally; verify manifest exists
info "Running local Vercel build…"
npx vercel build

if [[ -f .vercel/output/routes-manifest.json ]]; then
  ok "Found .vercel/output/routes-manifest.json ✅"
else
  err "Missing .vercel/output/routes-manifest.json after local vercel build."
  echo "Check: no 'output: \"export\"' in next.config.js, and Project Settings → Output Directory must be blank."
  exit 1
fi

# 10) Commit & push any fixes; print deploy command
info "Committing changes…"
git add -A
git commit -m "chore: auto-fix Vercel Next deploy (npm-only, no export, Sentry fix, app skeleton)" || true
git push || true

ok "Local Next build and Vercel build succeeded. Deploy with:"
echo "    vercel --prod"
