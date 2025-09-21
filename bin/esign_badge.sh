#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
targets=$(git ls-files 'products.html' 'sections/*.html' 'surfaces/sections/*.html' 2>/dev/null || true)
for f in $targets; do
  # add badge after first <h1> or <h2>
  perl -0777 -pe 's#(<h[12][^>]*>.*?</h[12]>)#$1\n<p class="chip-esign"><svg aria-hidden="true" viewBox="0 0 24 24"><path d="M9 12l2 2 4-4" stroke="currentColor" fill="none" stroke-width="2"/></svg> eSign ready</p>#is' -i "$f"
  # add CTA near any “What’s included” heading or after first paragraph
  perl -0777 -pe 's#(What[’'\''’]s included|What’s included)#\1</h3>\n<p><a class="btn-esign" href="/contact.html#esign">Request e-signature demo</a></p>#i' -i "$f"
  perl -0777 -pe 's#(<p[^>]*>)(?!.*btn-esign)(.*?)</p>#$1$2</p>\n<p><a class="btn-esign" href="/contact.html#esign">Request e-signature demo</a></p>#i' -i "$f"
done
echo "✅ eSign badge + CTA injected on product/section pages"
