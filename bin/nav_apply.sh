#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

# Link /assets/nav-fix.css once per page + add skip link and main#main
for f in $(git ls-files '*.html'); do
  # remove dupes, then add before </head>
  perl -0777 -pe 's#\s*<link[^>]*href="/assets/nav-fix\.css"[^>]*/?>\s*##ig' -i "$f"
  perl -0777 -pe 's#</head>#<link rel="stylesheet" href="/assets/nav-fix.css">\n</head>#i' -i "$f"

  # add skip link after <body> if missing
  grep -q 'class="skip-to-content"' "$f" || \
    perl -0777 -pe 's#<body([^>]*)>#<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>#i' -i "$f"

  # ensure <main id="main"> when missing
  perl -0777 -pe 's#<main(?![^>]*\bid=)[^>]*>#my $x=$&; $x=~s/<main/<main id="main"/i unless $x=~/\bid="/i; $x#eig' -i "$f"

  # normalize “Reports” links to /reports/
  perl -0777 -pe 's#href="(?:/)?reports(?:\.html)?"#href="/reports/"#g' -i "$f"
done
echo "✅ nav CSS linked + skip link + main#main + Reports URL normalized"
