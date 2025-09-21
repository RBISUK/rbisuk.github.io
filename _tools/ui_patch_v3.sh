#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ ERR line $LINENO: $BASH_COMMAND" >&2' ERR
git rev-parse --is-inside-work-tree >/dev/null || { echo "✖ not a git repo"; exit 1; }

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
echo "→ RBIS UI patch v3 @ $STAMP"
mkdir -p _backups

# —— backups (safe)
for f in index.html assets/rbis.css assets/rbis.js offerings.html products.html reports.html solutions.html trust.html about.html websites.html contact.html dashboard.html; do
  [ -f "$f" ] || continue
  mkdir -p "_backups/$(dirname "$f")"
  cp -f "$f" "_backups/${f}.${STAMP}"
done

# —— CSS: matte buttons + mobile + cards + outline variant
touch assets/rbis.css
if ! grep -q '/* RBIS UI v3 */' assets/rbis.css; then
cat >> assets/rbis.css <<'CSS'
/* RBIS UI v3 */
:root{
  --ink:#ecf3ff; --muted:#a9b2c3; --bg:#0b0e14;
  --btn-bg:#151e34; --btn-ink:#ecf3ff; --btn-br:#25335c;
  --btn-shadow:0 10px 24px rgba(0,12,40,.28);
  --btn-focus:#9fd1ff;
}
html,body{background:#0b0e14;color:var(--ink)}
.container{max-width:1200px;margin:0 auto;padding:0 16px}
@media(min-width:960px){.container{padding:0 20px}}
.section{padding:28px 0}@media(min-width:960px){.section{padding:40px 0}}
.muted{color:var(--muted)}
/* Cards unify */
.cards{display:grid;gap:14px;grid-template-columns:1fr}
@media(min-width:720px){.cards{grid-template-columns:repeat(2,1fr)}}
@media(min-width:1024px){.cards{grid-template-columns:repeat(3,1fr)}}
.card{display:flex;flex-direction:column;min-height:226px;background:#101526;border:1px solid #152041;border-radius:18px;padding:16px;box-shadow:0 10px 28px rgba(0,0,0,.16)}
.card footer{display:flex;gap:10px;align-items:center;justify-content:space-between;margin-top:auto}
/* Matte / posh buttons */
.cta,.btn,button[type=submit]{
  appearance:none;-webkit-appearance:none;display:inline-flex;align-items:center;justify-content:center;
  gap:10px;padding:12px 16px;border-radius:999px;font-weight:800;letter-spacing:.1px;
  background:var(--btn-bg)!important;color:var(--btn-ink)!important;border:1px solid var(--btn-br)!important;
  box-shadow:var(--btn-shadow);text-decoration:none;cursor:pointer;transition:transform .12s ease, filter .12s ease
}
.cta:hover,.btn:hover,button[type=submit]:hover{transform:translateY(-1px)}
.cta:active,.btn:active,button[type=submit]:active{transform:translateY(0);filter:brightness(.98)}
.cta:focus-visible,.btn:focus-visible,button[type=submit]:focus-visible{outline:2px solid var(--btn-focus);outline-offset:2px}
.btn.outline{background:transparent!important;color:var(--ink)!important;border:1px solid #2b3b68!important}
.btn.small{padding:9px 12px;font-weight:700}
/* Hero crest */
.hero--crest{position:relative;display:grid;gap:24px;align-items:center;grid-template-columns:1fr;min-height:68vh;padding:48px 0}
@media(min-width:960px){.hero--crest{grid-template-columns:1.1fr .9fr;min-height:76vh;padding:64px 0}}
.hero-copy h1{margin:.2rem 0 .6rem}
.hero-copy .sh{background:linear-gradient(90deg,#9fd1ff,#92ff72 60%,#9fb6ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.hero-copy .subsh{color:#e8ecf1;opacity:.92}
.hero-copy p{max-width:720px}
.cta-row{display:flex;flex-wrap:wrap;gap:12px;margin-top:14px}
.hero-art{text-align:center}
.crest-wrap{aspect-ratio:1/1;max-width:520px;margin:0 auto;filter:drop-shadow(0 24px 64px rgba(0,0,0,.35))}
.crest{width:100%;height:auto;animation:rbisSpin 18s linear infinite;transform:translateZ(0)}
@keyframes rbisSpin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
/* Parallax hook */
.hero--crest .crest-wrap{transform:translateY(calc(var(--p,0) * -6px))}
.hero--crest .hero-copy{transform:translateY(calc(var(--p,0) * -3px))}
CSS
fi

# —— JS: parallax
touch assets/rbis.js
if ! grep -q '/* RBIS hero parallax v3 */' assets/rbis.js; then
cat >> assets/rbis.js <<'JS'
/* RBIS hero parallax v3 */
(()=>{let t=!1;const n=()=>{const e=window.scrollY||0;document.documentElement.style.setProperty("--p",String(Math.max(0,Math.min(1,e/600)))),t=!1};window.addEventListener("scroll",()=>{t||(requestAnimationFrame(n),t=!0)},{passive:!0});n()})();
JS
fi

# —— HERO inject/replace on home
read -r -d '' HERO <<"HEROHTML"
<section class="hero hero--crest">
  <div class="hero-copy">
    <h1><span class="sh">Behavioural Intelligence</span><br><span class="subsh">Built for Decisions.</span></h1>
    <p class="muted">Evidence-led analysis, psychology in design, and audit-ready software. RBIS blends human behavioural science with pragmatic engineering to help leaders act with confidence.</p>
    <div class="cta-row">
      <a class="cta" href="/offerings.html">Products &amp; Services</a>
      <a class="btn" href="/reports.html">Professional Reports</a>
      <a class="btn outline" href="/contact.html">Contact</a>
    </div>
  </div>
  <div class="hero-art" aria-hidden="true">
    <div class="crest-wrap">
      <svg class="crest" viewBox="0 0 160 160" role="img" aria-label="RBIS crest">
        <defs><linearGradient id="rbis-lg" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#7cf"/><stop offset="55%" stop-color="#92ff72"/><stop offset="100%" stop-color="#9fb6ff"/>
        </linearGradient></defs>
        <g fill="url(#rbis-lg)">
          <path d="M80 6 138 34 154 80 138 126 80 154 22 126 6 80 22 34Z" opacity=".18"/>
          <path d="M80 16 128 40 144 80 128 120 80 144 32 120 16 80 32 40Z" opacity=".28"/>
          <path d="M80 28 116 46 132 80 116 114 80 132 44 114 28 80 44 46Z" opacity=".42"/>
          <circle cx="80" cy="80" r="16" opacity=".94"/>
        </g>
      </svg>
    </div>
  </div>
</section>
HEROHTML

if [ -f index.html ]; then
  if perl -0777 -ne 'exit(!(m/<section[^>]*class="[^"]*\bhero\b/si))' index.html; then
    RBIS_HERO="$HERO" perl -0777 -pe 'BEGIN{$h=$ENV{RBIS_HERO}} s~<section[^>]*class="[^"]*\bhero\b[^"]*"[^>]*>.*?</section>~$h~s' -i index.html
  else
    awk -v H="$HERO" 'BEGIN{d=0} /<main[^>]*>/ && !d {print; print H; d=1; next} {print} END{if(!d) print H}' index.html > .tmp && mv .tmp index.html
  fi
  # ensure rbis.js is referenced
  if ! grep -q 'assets/rbis.js' index.html; then
    awk -v s="<script src=\"/assets/rbis.js?v=${STAMP}\" defer></script>" '/<\/body>/{print s RS $0; next} {print}' index.html > .tmp && mv .tmp index.html
  else
    sed -i "s#assets/rbis\.js[^\"]*#assets/rbis.js?v=${STAMP}#g" index.html
  fi
fi

# —— Remove any “Talk to RBIS” floater/box site-wide
shopt -s nullglob
for f in *.html; do
  perl -0777 -pe 's~(<[^>]+(?:id|class)\s*=\s*"[^"]*(talk|cta)[^"]*"[^>]*>[^<]*?talk\s*to\s*rbis.*?</[^>]+>)~<!-- RBIS: removed $1 -->~ig' -i "$f"
  perl -0777 -pe 's~(<a[^>]*>[^<]*?talk\s*to\s*rbis[^<]*?</a>)~<!-- RBIS: removed $1 -->~ig' -i "$f"
  perl -0777 -pe 's~(<section[^>]*>.*?talk\s*to\s*rbis.*?</section>)~<!-- RBIS: removed $1 -->~ig' -i "$f"
done

# —— Commit + push
git add -A
git commit -m "ui(v3): crest hero + matte CTAs + mobile/card polish + remove Talk to RBIS (${STAMP})" || echo "ℹ️ no changes to commit"
git push

# —— Quick checks
echo "— headers:"
for u in / /offerings.html /reports.html; do
  curl -sSI "https://www.rbisintelligence.com${u}?v=${STAMP}" | sed -n '1,8p' || true
done
echo "— crest present?"
curl -s "https://www.rbisintelligence.com/?v=${STAMP}" | grep -i -E 'rbis-lg|class="crest"|hero--crest' || echo "⚠️ crest not detected (hard refresh)"
echo "— floater gone (local scan):"
grep -RNi --include="*.html" "Talk to RBIS" || echo "✔️ no local matches"
