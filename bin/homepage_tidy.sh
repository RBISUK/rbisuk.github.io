#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# 0) Make sure CSS file exists
mkdir -p assets
touch assets/site.v2.css

# 1) Remove the old inline <nav> that was embedded inside the hero on the homepage
#    (keeps the proper site-wide header you already inject).
if [[ -f index.html ]]; then
  perl -0777 -i -pe 's#(<section\b[^>]*class="[^"]*\bhero\b[^"]*"[^>]*>\s*)<nav\b.*?</nav>\s*#$1#is' index.html
fi

# 2) Append HERO v2 styles (only once)
if ! grep -q '/* RBIS:HEROv2 */' assets/site.v2.css; then
  cat >> assets/site.v2.css <<'CSS'
/* RBIS:HEROv2 */
:root{
  --rbis-max:1120px;
  --rbis-gap:16px;
  --rbis-surface:rgba(255,255,255,.72);
  --rbis-border:rgba(0,0,0,.08);
  --rbis-text:#111;
}
@media (prefers-color-scheme:dark){
  :root{--rbis-surface:rgba(15,15,18,.70);--rbis-border:rgba(255,255,255,.12);--rbis-text:#f3f3f3;}
}

/* Hero container */
.hero{
  max-width:var(--rbis-max);
  margin:0 auto;
  padding:clamp(24px,8vw,96px) var(--rbis-gap);
  display:grid;
  grid-template-columns:1fr;
  gap:24px;
}
@media (min-width:900px){
  .hero{grid-template-columns:1.2fr .8fr; align-items:center;}
}

/* Kicker becomes a neat label (no vertical writing on mobile) */
.kicker{
  display:inline-block;
  margin-bottom:8px;
  text-transform:uppercase;
  letter-spacing:.14em;
  font-weight:700;
  font-size:.8rem;
  color:#2f6fed;
  writing-mode:initial;
  transform:none;
}

/* Typography */
.hero h1{
  font-size:clamp(28px,6.4vw,56px);
  line-height:1.08;
  letter-spacing:-.02em;
  margin:8px 0 12px;
  color:var(--rbis-text);
}
.hero .lead{
  font-size:clamp(16px,2.9vw,19px);
  color:rgba(17,17,17,.82);
  max-width:64ch;
  margin:0 0 16px 0;
}
@media (prefers-color-scheme:dark){
  .hero .lead{color:rgba(243,243,243,.86);}
}

/* CTAs */
.cta-row{
  display:flex;
  gap:12px;
  align-items:center;
  flex-wrap:wrap;
  margin-top:8px;
}
.btn,.btn-ghost{
  display:inline-flex;align-items:center;justify-content:center;
  padding:12px 18px;border-radius:14px;font-weight:700;text-decoration:none;
  border:1px solid var(--rbis-border);
}
.btn{background:#111;color:#fff;border-color:#111;}
@media (prefers-color-scheme:dark){.btn{background:#fff;color:#111;border-color:#fff}}
.btn-ghost{background:transparent}

/* Pill drops to its own line on small screens so it never overlaps */
.pill{
  display:inline-flex;align-items:center;gap:8px;
  padding:8px 12px;border-radius:12px;
  background:rgba(0,0,0,.04);border:1px solid var(--rbis-border);
}
@media (prefers-color-scheme:dark){.pill{background:rgba(255,255,255,.06)}}
@media (max-width:600px){.pill{flex-basis:100%}}

/* Right column gets a subtle placeholder surface (optional) */
.hero-side{
  min-height:140px;
  border-radius:20px;
  background:
    radial-gradient(60% 60% at 0% 0%, rgba(0,0,0,.06), rgba(0,0,0,0));
}
CSS
fi

echo "Homepage tidy applied."
