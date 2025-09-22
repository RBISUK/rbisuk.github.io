#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

# Collect HTML files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -d '' -t FILES < <(git ls-files -z '*.html')
else
  mapfile -d '' -t FILES < <(find . -type f -name '*.html' -print0)
fi

for f in "${FILES[@]}"; do
  # 1) Wrap raw JSON-LD printed as text between tags
  #    …> { "@context":"https://schema.org", … } <…
  perl -0777 -pe 's{(>)(\s*)({[^<]*"@context"\s*:\s*"https?:\/\/schema\.org"[^<]*})(\s*)(<)}{$1$2<script type="application/ld+json">$3</script>$4$5}igs' -i "$f" || true

  # 2) Add missing type to JSON-LD <script> blocks that already exist
  perl -0777 -pe 's{<script(?![^>]*\btype=)([^>]*)>\s*({[^<]*"@context"\s*:\s*"https?:\/\/schema\.org"[^<]*})\s*</script>}{<script type="application/ld+json"$1>$2</script>}igs' -i "$f" || true

  # 3) Normalise skip link: remove any variant, insert standard once after <body>
  perl -0777 -pe 's#\s*<a\b[^>]*(?:id|class)="[^"]*\bskip[- _]?to[- _]?content\b"[^>]*>.*?</a>\s*##igs' -i "$f" || true
  if ! grep -qi 'class="skip-to-content"' "$f"; then
    perl -0777 -pe 's{<body([^>]*)>}{<body$1>\n<a class="skip-to-content" href="#main">Skip to content</a>}i' -i "$f" || true
  fi

  # 4) Ensure <main id="main"> when missing
  perl -0777 -pe 's{<main(?![^>]*\bid=)[^>]*>}{ my $x=$&; $x=~s/<main/<main id="main"/i; $x }eig' -i "$f" || true
done

echo "✅ JSON-LD + skip-to-content normalised on ${#FILES[@]} files."
echo -n "— JSON-LD typed count: "; grep -RIn --include='*.html' 'application/ld\+json' . | wc -l || true
echo -n "— skip-to-content count: "; grep -RIn --include='*.html' 'class=\"skip-to-content\"' . | wc -l || true
