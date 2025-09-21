#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
for f in $(git ls-files '*.html'); do
  # A) If link already has rel="", append tokens (dedupe later)
  perl -0777 -pe '
    s{(<a\b[^>]*href="https?://[^"]+"[^>]*\brel=")([^"]*)(")}
     { my ($pre,$val,$post)=($1,$2,$3);
       my %seen = map { $_=>1 } split(/\s+/,$val), qw(noopener noreferrer);
       "$pre".join(" ", sort keys %seen)."$post"
     }ige;
  ' -i "$f"
  # B) If link has no rel="", add one
  perl -0777 -pe '
    s{(<a\b(?=[^>]*href="https?://[^"]+")(?![^>]*\brel=")[^>]*?)>}
     {$1 . " rel=\"noopener noreferrer\">" }ige;
  ' -i "$f"
  # C) Compact accidental duplicates
  perl -0777 -pe '
    s/rel="([^"]*)"/my %s=(); my @t=grep{!$s{$_}++} split(/\s+/,$1); "rel=\"".join(" ",@t)."\""/ge;
  ' -i "$f"
done
echo "✅ external links hardened"
