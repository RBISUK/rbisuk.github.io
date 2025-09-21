#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

# Add /assets/nav-fix.css once per page; ensure skip link + <main id="main">
for f in $(git ls-files '*.html'); do
  # clean dupes
  perl -0777 -pe 's#\s*<link[^>]*href="/assets/nav-fix\.css"[^>]*/?>\s*##ig' -i "$f"
  # add link before </head>
  perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f"
  # skip link
  grep -q 'class="skip-to-content"' "$f" || \
    perl -0777 -pe 's#<body([^>]*)>#<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>#i' -i "$f"
  # main id
  perl -0777 -pe 's#<main(?![^>]*\bid=)[^>]*>#my $x=$&; $x=~s/<main/<main id="main"/i unless $x=~/\bid="/i; $x#eig' -i "$f"
done

# Wrap first <nav> in details/summary burger if not already done
for f in $(git ls-files '*.html'); do
  rg -q 'class="[^"]*\brbis-nav\b' "$f" && continue || true
  perl -0777 -pe '
    s#(<nav\b[^>]*>)(.*?)(</nav>)#
      $1 . q{<details class="rbis-nav"><summary class="rbis-burger"><span class="rbis-sr">Menu</span></summary><div class="rbis-drawer"><div class="rbis-nav-row">}
      . $2 . q{</div></div></details>} . $3#s
  ' -i "$f"
done

# Fix "Reports" link to go to /reports/
for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's#href="(/)?reports\.html"#href="/reports/"#g' -i "$f"
done
