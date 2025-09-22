#!/usr/bin/env bash
# Apply professional nav styling + structure site-wide (safe & idempotent)

set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${PWD}"

# ---------- 0) Files list (skip backups) ----------
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi
# drop backups
TMP=()
for f in "${FILES[@]}"; do [[ "$f" == */_backups/* ]] || TMP+=("$f"); done
FILES=("${TMP[@]}")

# ---------- 1) CSS: add NAV v2 once ----------
mkdir -p assets
touch assets/site.v2.css
if ! grep -q 'RBIS:NAVV2' assets/site.v2.css; then
  cat >> assets/site.v2.css <<'CSS'
/* ===== RBIS:NAVV2 (professional) ===== */
:root{
  --nav-h: 64px;
  --surface: #fff;
  --text: #0b1220;
  --muted: #5e677a;
  --border: rgba(12,16,24,.08);
  --accent: #0a66ff;
  --shadow: 0 6px 24px rgba(2,6,23,.08);
}
/* sticky translucent bar */
nav[aria-label="Primary"]{
  position: sticky; top: 0; z-index: 1000;
  backdrop-filter: saturate(1.15) blur(10px);
  background: color-mix(in oklab, var(--surface) 90%, transparent);
  border-bottom: 1px solid var(--border);
  display:flex; align-items:center; height: var(--nav-h);
  padding: 0 16px; gap: 16px;
}
@media (min-width:1200px){ nav[aria-label="Primary"]{ padding:0 24px; } }
/* brand */
nav[aria-label="Primary"] .brand{
  margin-right:auto; text-decoration:none; color:var(--text);
  font-weight:800; letter-spacing:.2px; font-size:1.05rem;
}
nav[aria-label="Primary"] .brand:hover{ opacity:.85; }
/* details menu */
.rbis-menu{ position:relative; margin-left:auto; }
.rbis-burger{
  list-style:none; cursor:pointer; user-select:none;
  display:inline-flex; align-items:center; gap:10px;
  border:1px solid var(--border); border-radius:12px;
  padding:10px 12px; font-weight:600; color:var(--text);
}
.rbis-burger::-webkit-details-marker{ display:none; }
/* dropdown (mobile) */
.rbis-menu>ul{
  position:absolute; right:8px; top:calc(100% + 8px); min-width:220px;
  background:var(--surface); border:1px solid var(--border);
  border-radius:14px; box-shadow:var(--shadow);
  padding:6px; margin:0; display:none;
}
.rbis-menu[open]>ul{ display:block; }
.rbis-menu>ul li{ list-style:none; }
.rbis-menu>ul a{
  display:flex; align-items:center; gap:10px;
  color:var(--text); text-decoration:none; font-weight:500;
  padding:10px 12px; border-radius:10px;
}
.rbis-menu>ul a:hover,
.rbis-menu>ul a:focus-visible{ background:rgba(2,6,23,.06); outline:none; }
/* current page */
.rbis-menu>ul a[aria-current="page"]{
  background:rgba(10,102,255,.12); color:#0a3fd1;
}
/* desktop: inline */
@media (min-width:960px){
  .rbis-menu{ all:unset; margin-left:auto; display:flex; align-items:center; }
  .rbis-menu>summary{ display:none; }
  .rbis-menu>ul{ all:unset; display:flex; gap:6px; margin:0; padding:0; }
  .rbis-menu>ul li{ list-style:none; }
  .rbis-menu>ul a{ padding:10px 14px; border-radius:10px; }
}
/* shadow on scroll (optional—toggle body.scrolled) */
body.scrolled nav[aria-label="Primary"]{ box-shadow: var(--shadow); }
CSS
  echo "➕ Added NAV v2 CSS to assets/site.v2.css"
fi

# ---------- 2) Ensure rbis.css imports site.v2.css (once) ----------
if [[ -f assets/rbis.css ]] && ! grep -q 'site.v2.css' assets/rbis.css; then
  sed -i '1i @import url("/assets/site.v2.css");' assets/rbis.css
  echo "➕ Added @import to assets/rbis.css"
fi

# canonical nav snippet
read -r -d '' NAV <<"HTML"
<header class="site-header">
  <nav aria-label="Primary"><a class="brand" href="/index.html">RBIS</a><details class="rbis-menu" role="navigation"><summary class="rbis-burger" aria-label="Menu">Menu</summary>
  <ul>
    <li><a href="/solutions.html">Solutions</a></li>
    <li><a href="/reports/">Reports</a></li>
    <li><a href="/products.html">Products</a></li>
    <li><a href="/about.html">About</a></li>
    <li><a href="/contact.html">Contact</a></li>
  </ul>
  </details></nav>
</header>
HTML

changed=0
for f in "${FILES[@]}"; do
  # only operate on full pages
  grep -qi '<body\b' "$f" || continue

  # 2a) Remove any inline runtime nav/sw (safe if absent)
  perl -0777 -i -pe 's#<script id="nav-current">.*?</script>\s*##gis; s#<script id="sw-register">.*?</script>\s*##gis' "$f"

  # 2b) Ensure a clean single skip link
  perl -0777 -i -pe 's/class="skip-to-content[^"]*"/class="skip-to-content"/gi' "$f"
  perl -0777 -i -pe 's{(<body\b[^>]*>)}{$1\n<a class="skip-to-content" href="#main">Skip to content</a>}i unless /class="skip-to-content"/i' "$f"

  # 2c) Ensure the page links the base stylesheet (so nav CSS arrives via import)
  if ! grep -qi '/assets/rbis\.css' "$f"; then
    awk '
      /<\/head>/ && !done { print "  <link rel=\"stylesheet\" href=\"/assets/rbis.css\">"; done=1 }
      { print }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi

  # 2d) Drop ALL existing primary navs (we’ll insert one in the right place)
  perl -0777 -i -pe 's#<nav\b[^>]*\baria-label="Primary"[^>]*>.*?</nav>\s*##gis' "$f"

  # 2e) Insert canonical header+nav right AFTER the skip link (once)
  if ! grep -qi 'class="site-header"' "$f"; then
    awk -v IGNORECASE=1 -v nav="$NAV" '
      BEGIN{added=0}
      {
        print $0
        if (!added && $0 ~ /class="skip-to-content"/) { print nav; added=1 }
      }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi

  # 2f) Ensure <main> has id="main" (but don’t try to create a new main)
  perl -0777 -i -pe 's/<main(?![^>]*\bid=)/<main id="main"/ig' "$f"

  changed=$((changed+1))
done

# ---------- 3) Quick summary ----------
echo "—— Summary ——"
echo "HTML files scanned: ${#FILES[@]}"
echo -n "Pages with header.site-header: "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="site-header"' . | wc -l
echo -n "Pages with skip link:         "; grep -RIl --include='*.html' --exclude-dir='_backups' 'class="skip-to-content"' . | wc -l
echo -n "<main id=\"main\"> present:    "; grep -RIl --include='*.html' --exclude-dir='_backups' '<main id="main"' . | wc -l
echo -n "Inline nav/sw scripts left:   "; grep -RIn --include='*.html' --exclude-dir='_backups' -E 'id="(nav-current|sw-register)"' . | wc -l
echo "Done."
