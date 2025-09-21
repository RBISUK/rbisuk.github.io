#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

mkdir -p assets

# 1) Drop a tiny override stylesheet (no Tailwind needed)
cat > assets/nav-fix.css <<'CSS'
/* RBIS nav rescue — overrides only (keeps your brand styles) */

/* Make the site header sticky and clearly separated from the hero */
body > header{
  position:sticky; top:0; z-index:50;
  background:rgba(255,255,255,.88);
  -webkit-backdrop-filter:saturate(180%) blur(8px);
  backdrop-filter:saturate(180%) blur(8px);
  border-bottom:1px solid rgba(0,0,0,.06);
}

/* Remove bullets/indent and lay out items in a tidy row (wrap on small) */
header nav ul, nav ul{
  list-style:none; margin:0; padding:0;
  display:flex; gap:.75rem; align-items:center; flex-wrap:wrap;
}

/* Normalize LI spacing */
header nav li, nav li{ margin:0; }

/* Compact the “pills” so they don’t dominate on iPhone */
header nav a, nav a{
  text-decoration:none; display:inline-block;
  padding:.40rem .70rem; border-radius:.60rem; line-height:1.2;
}
@media (max-width:640px){
  header nav a, nav a{ padding:.38rem .62rem; font-weight:600; }
}

/* Keep anchored sections from tucking under the sticky header */
:target{ scroll-margin-top:72px; }
CSS

# 2) Remove Tailwind CDN runtime if present (no-op if not there)
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's#\s*<script[^>]*cdn\.tailwindcss\.com[^>]*></script>\s*##ig' -i "$f"
done

# 3) Ensure our override stylesheet is linked once per page
for f in $(git ls-files '*.html'); do
  if ! grep -qiE '<link[^>]+href="/assets/nav-fix\.css"' "$f"; then
    perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f"
  fi
  # Deduplicate in case of multiple runs
  perl -0777 -pe 'my %seen; s#(<link[^>]+href="/assets/nav-fix\.css"[^>]*>)#($seen{$1}++ ? "" : $1)#egi' -i "$f"
done

git add -A
git commit -m "fix(nav): pure-CSS rescue (no bullets, compact pills, sticky header) + remove Tailwind CDN" || true
git push
