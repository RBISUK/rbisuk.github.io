#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

for f in $(git ls-files '*.html'); do
  perl -0777 -pe 's#\s*<link[^>]*href="/assets/nav-fix\.css"[^>]*/?>\s*##ig' -i "$f"
  perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f"

  grep -q 'class="skip-to-content"' "$f" || \
    perl -0777 -pe 's#<body([^>]*)>#<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>#i' -i "$f"

  perl -0777 -pe 's#<main(?![^>]*\bid=)[^>]*>#my $x=$&; $x=~s/<main/<main id="main"/i unless $x=~/\bid="/i; $x#eig' -i "$f"

  perl -0777 -pe 's#href="(?:/)?reports(?:\.html)?"#href="/reports/"#g' -i "$f"
done
echo "✅ nav CSS linked + skip link + main#main + Reports URL normalized"
