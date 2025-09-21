#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

# 1) Ensure nav CSS is linked once per page and add skip link + main#main
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's#\s*<link[^>]*href="/assets/nav-fix\.css"[^>]*/?>\s*##ig' -i "$f"
  perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f"
  grep -q 'class="skip-to-content"' "$f" || \
    perl -0777 -pe 's#<body([^>]*)>#<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>#i' -i "$f"
  perl -0777 -pe 's#<main(?![^>]*\bid=)[^>]*>#my $x=$&; $x=~s/<main/<main id="main"/i unless $x=~/\bid="/i; $x#eig' -i "$f"
done

# 2) Wrap the first <nav> with a details/summary hamburger (only if not already wrapped)
for f in $(git ls-files '*.html'); do
  grep -q 'class="rbis-nav"' "$f" && continue || true
  perl -0777 -pe '
    s#(<header\b[^>]*>)(.*?<nav\b[^>]*>)(.*?)(</nav>)(.*?</header>)#
      $1 .
      q{<details class="rbis-nav"><summary class="rbis-burger"><span class="rbis-sr">Menu</span></summary><div class="rbis-drawer"><div class="rbis-nav-row">}
      . $3 .
      q{</div></div></details>} .
      $5
    #sxe
  ' -i "$f"
done

# 3) Normalise "Reports" link to directory URL
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's#href="(/)?reports\.html"#href="/reports/"#g' -i "$f"
done
