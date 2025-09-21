#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

mkdir -p assets

# 1) Append/ensure CSS overrides (keeps brand styles; works without Tailwind)
#    Safe to run multiple times; we dedupe the block.
block_start='/* RBIS HAMBURGER START */'
block_end='/* RBIS HAMBURGER END */'

css_file="assets/nav-fix.css"
touch "$css_file"
awk -v s="$block_start" -v e="$block_end" '
  BEGIN{skip=0}
  $0 ~ s {skip=1}
  !skip {print}
  $0 ~ e {skip=0}
' "$css_file" > "$css_file.tmp" && mv "$css_file.tmp" "$css_file"

cat >> "$css_file" <<'CSS'
/* RBIS HAMBURGER START */
/* Sticky, translucent header to separate from hero */
body > header{
  position:sticky; top:0; z-index:50;
  background:rgba(255,255,255,.88);
  -webkit-backdrop-filter:saturate(180%) blur(8px);
  backdrop-filter:saturate(180%) blur(8px);
  border-bottom:1px solid rgba(0,0,0,.06);
}

/* Base nav layout (desktop) */
header nav ul, nav ul{ list-style:none; margin:0; padding:0; display:flex; gap:1rem; align-items:center; }
header nav li, nav li{ margin:0; }
header nav a, nav a{ text-decoration:none; display:inline-block; padding:.40rem .70rem; border-radius:.60rem; line-height:1.2; }

/* Details-based burger */
.rbis-menu{ display:block; }
.rbis-burger{
  display:none; cursor:pointer; user-select:none;
  border-radius:.6rem; padding:.5rem .7rem; font-weight:700;
}

/* Cute burger icon using CSS only */
.rbis-burger::before, .rbis-burger::after{
  content:""; display:inline-block; width:22px; height:2px; background:#111; vertical-align:middle;
  box-shadow: 0 -6px 0 #111, 0 6px 0 #111; border-radius:2px; transition:.2s transform, .2s box-shadow, .2s opacity;
}
.rbis-menu[open] .rbis-burger::before{ box-shadow:none; transform:rotate(45deg); }
.rbis-menu[open] .rbis-burger::after{ position:relative; left:-22px; transform:rotate(-45deg); }

/* Mobile panel */
@media (max-width: 768px){
  /* show burger; turn list into panel */
  .rbis-burger{ display:inline-flex; align-items:center; gap:.5rem; }
  header nav ul, nav ul{
    display:none; flex-direction:column; gap:.25rem; background:#fff; border:1px solid rgba(0,0,0,.08);
    border-radius:.8rem; padding:.5rem; margin:.5rem 0 0 0;
    box-shadow:0 6px 20px rgba(0,0,0,.06);
  }
  .rbis-menu[open] > ul{ display:flex; }

  /* keep anchors from sliding under sticky header */
  :target{ scroll-margin-top:72px; }
}

/* Desktop keeps normal inline nav; hide burger */
@media (min-width: 769px){
  .rbis-burger{ display:none }
  .rbis-menu > ul{ display:flex !important; background:transparent; border:0; padding:0; margin:0; box-shadow:none; }
}
/* RBIS HAMBURGER END */
CSS

# 2) Remove Tailwind CDN runtime (if any) — keeps things deterministic
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's#\s*<script[^>]*cdn\.tailwindcss\.com[^>]*></script>\s*##ig' -i "$f" || true
done

# 3) Wrap the first <ul> inside each <nav> with <details>/<summary> (once per file)
for f in $(git ls-files '*.html'); do
  grep -qi 'rbis-menu' "$f" && continue  # already converted
  perl -0777 -pe '
    # Only if there is a <nav> section
    if (m/<nav\b[^>]*>.*?<\/nav>/si && index($_,"rbis-menu")==-1) {
      s{
        (<nav\b[^>]*>.*?)
        (<ul\b.*?<\/ul>)
      }{
        my ($pre,$ul)=($1,$2);
        $pre .
        qq{<details class="rbis-menu" role="navigation">}
        . qq{<summary class="rbis-burger" aria-label="Menu">Menu</summary>\n}
        . $ul .
        qq{\n</details>}
      }esix;
    }
  ' -i "$f"
done

# 4) Ensure our CSS is linked once, at the end of <head>
for f in $(git ls-files '*.html'); do
  if ! grep -qiE '<link[^>]+href="/assets/nav-fix\.css"' "$f"; then
    perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f"
  fi
  # Deduplicate
  perl -0777 -pe 'my %seen; s#(<link[^>]+href="/assets/nav-fix\.css"[^>]*>)#($seen{$1}++ ? "" : $1)#egi' -i "$f"
done

echo "✅ Hamburger nav injected + CSS written to /assets/nav-fix.css"
