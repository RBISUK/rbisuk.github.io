#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

css="assets/nav-fix.css"
touch "$css"

# 1) Add tiny a11y helper + hide any visible "Menu" text (idempotent)
if ! grep -q 'RBIS HAMBURGER ICON START' "$css" 2>/dev/null; then
  cat >> "$css" <<'CSS'
/* RBIS HAMBURGER ICON START */
.rbis-burger{ font-size:0; min-width:44px; min-height:44px; } /* tap target + hide text */
.rbis-burger .rbis-sr{
  position:absolute!important;width:1px;height:1px;padding:0;margin:-1px;
  overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0;
}
/* RBIS HAMBURGER ICON END */
CSS
fi

# 2) Swap any visible "Menu" text inside the burger for a screen-reader-only label
for f in $(git ls-files '*.html'); do
  perl -0777 -pe '
    s{
      (<summary\b[^>]*class="[^"]*\brbis-burger\b[^"]*"[^>]*>)
      (.*?)
      (</summary>)
    }{$1 . q{<span class="rbis-sr">Menu</span>} . $3}esig;
  ' -i "$f"
done

echo "✅ Hamburger uses icon-only (with SR label)."
