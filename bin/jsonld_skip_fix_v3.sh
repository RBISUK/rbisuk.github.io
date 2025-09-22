#!/usr/bin/env bash
# v3 — Ensure JSON-LD + normalise skip link and main landmark

set -Eeuo pipefail; IFS=$'\n\t'

BASE_URL="https://www.rbisintelligence.com"

# Collect HTML files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # 1) If a JSON-LD <script> exists but lacks type=, add it
  perl -0777 -pe 's{<script(?![^>]*\btype=)([^>]*)>\s*({[^<]*"@context"\s*:\s*"https?:\/\/schema\.org"[^<]*})\s*</script>}
                  {<script type="application/ld+json"$1>$2</script>}igs' -i "$f" || true

  # 2) If raw JSON-LD appears outside a script, wrap it
  perl -0777 -pe 's{(>)(\s*)({[^<]*"@context"\s*:\s*"https?:\/\/schema\.org"[^<]*})(\s*)(<)}
                  {$1$2<script type="application/ld+json">$3</script>$4$5}igs' -i "$f" || true

  # 3) If still NO JSON-LD, inject minimal WebPage JSON-LD before </head>
  if ! grep -qi 'application/ld+json' "$f"; then
    rel="${f#./}"
    if [[ "$rel" == "index.html" ]]; then
      page_url="$BASE_URL/"
    elif [[ "$rel" == */index.html ]]; then
      page_url="$BASE_URL/${rel%index.html}"
    else
      page_url="$BASE_URL/${rel}"
    fi
    title="$(perl -0777 -ne 'if (m|<title>(.*?)</title>|is){ $t=$1; $t=~s/\s+/ /g; print $t; }' "$f" || true)"
    [[ -z "${title:-}" ]] && title="RBIS"

    json_min='{"@context":"https://schema.org","@type":"WebPage","url":"'"$page_url"'","name":"'"$title"'"}'
    esc_json="$(printf '%s' "$json_min" | sed -e 's/[\/&]/\\&/g')"
    perl -0777 -pe "s#</head>#<script type=\"application/ld+json\">$esc_json</script>\n</head>#i" -i "$f" || true
  fi

  # 4) Normalise skip link: remove variants, add our standard one once
  perl -0777 -pe 's#\s*<a\b[^>]*(?:id|class)="[^"]*\bskip[- _]?to[- _]?content\b"[^>]*>.*?</a>\s*##igs' -i "$f" || true
  if ! grep -qi 'class="skip-to-content"' "$f"; then
    perl -0777 -pe 's{<body([^>]*)>}{<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>}i' -i "$f" || true
  fi

  # 5) Ensure <main id="main"> (don’t overwrite existing ids)
  perl -0777 -pe 's{<main(?![^>]*\bid=)[^>]*>}{ my $x=$&; $x=~s/<main/<main id="main"/i; $x }eig' -i "$f" || true
done

echo "✅ JSON-LD + skip-to-content normalised on ${#FILES[@]} files."
echo -n "— JSON-LD typed count:   "; grep -RIn --include='*.html' 'application/ld\+json' . | wc -l || true
echo -n "— skip-to-content count: "; grep -RIn --include='*.html' 'class=\"skip-to-content\"' . | wc -l || true
