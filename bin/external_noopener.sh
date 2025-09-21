#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'

# Harden external links: ensure rel="noopener noreferrer" is present and deduped.
for f in $(git ls-files '*.html'); do
  # A) If an <a> has external href and NO rel=, add one (no look-behind used)
  perl -0777 -pe '
    s{<a\b([^>]*href="https?://[^"]+"[^>]*)>}
     { my $attrs = $1;
       if ($attrs !~ /\brel="/i) { "<a$attrs rel=\"noopener noreferrer\">" }
       else { "<a$attrs>" }
     }ige;
  ' -i "$f"

  # B) If rel= exists, ensure tokens are present and dedupe
  perl -0777 -pe '
    s{rel="([^"]*)"}
     { my %seen=();
       my @tokens = grep { length && !$seen{$_}++ } (split(/\s+/,$1), qw(noopener noreferrer));
       "rel=\"" . join(" ", @tokens) . "\""
     }ige;
  ' -i "$f"
done

echo "✅ external links hardened (noopener+noreferrer, deduped)"
