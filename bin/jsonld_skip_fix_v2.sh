#!/usr/bin/env bash
# Adds/fixes <script type="application/ld+json">…</script> and normalises skip link

set -Eeuo pipefail; IFS=$'\n\t'

BASE_URL="https://www.rbisintelligence.com"

# Collect HTML files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # 1) If a JSON-LD <script> exists but is missing type=, add it
  perl -0777 -pe 's{<script(?![^>]*\btype=)([^>]*)>\s*({[^<]*"@context"\s*:\s*"https?:\/\/schema\.org"[^<]*})\s*</script>}
                  {<script type="application/ld+json"$1>$2</script>}igs' -i "$f" || true

  # 2) If raw JSON-LD text appears outside a script, wrap it
  perl -0777 -pe 's{(>)(\s*)({[^<]*"@context"\s*:\s*"https?:\/\/schema\.org"[^<]*})(\s*)(<)}
                  {$1$2<script type="application/ld+json">$3</script>$4$5}igs' -i "$f" || true

  # 3) If still NO JSON-LD present, inject minimal WebPage JSON-LD before </head>
  if ! grep -qi 'application/ld+json' "$f"; then
    rel="${f#./}"
    # Build page URL from file path
    if [[ "$rel" == "index.html" ]]; then
      page_url="$BASE_URL/"
    elif [[ "$rel" == */index.html ]]; then
      page_url="$BASE_URL/${rel%index.html}"
    else
      page_url="$BASE_URL/${rel}"
    fi
    # Extract <title> (fallback to file name / site name)
    title="$(perl -0777 -ne 'if (m|<title>(.*?)</title>|is){ $t=$1; $t=~s/\s+/ /g; print $t; }' "$f" || true)"
    [[ -z "${title:-}" ]] && title="RBIS"

    # One-line JSON to avoid newline escaping in Perl replace
    json='{"@context":"https://schema.org","@type":"WebPage","url":"'"$page_url"'","name":"'"$title"'"}'
    # Escape for regex replacement
    esc_json="$(printf '%s' "$json" | sed -e 's/[\/&]/\\&/g')"

    perl -0777 -pe "s#</head>#<script type=\"application/ld+json\">$esc_json</script>\n</head>#i" -i "$f" || true
  fi

  # 4) Normalise the skip link (remove any variant, add our standard one once)
  perl -0777 -pe 's#\s*<a\b[^>]*(?:id|class)="[^"]*\bskip[- _]?to[- _]?content\b"[^>]*>.*?</a>\s*##igs' -i "$f" || true
  if ! grep -qi 'class="skip-to-content"' "$f"; then
    perl -0777 -pe 's{<body([^>]*)>}{<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>}i' -i "$f" || true
  fi

  # 5) Ensure <main id="main"> exists (don’t overwrite other ids)
  perl -0777 -pe 's{<main(?![^>]*\bid=)[^>]*>}{ my $x=$&; $x=~s/<main/<main id="main"/i; $x }eig' -i "$f" || true
done

# Summaries
echo "✅ JSON-LD + skip-to-content normalised on ${#FILES[@]} files."
echo -n "— JSON-LD typed count: "; grep -RIn --include='*.html' 'application/ld\+json' . | wc -l || true
echo -n "— skip-to-content count: "; grep -RIn --include='*.html' 'class=\"skip-to-content\"' . | wc -l || true
