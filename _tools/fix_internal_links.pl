#!/usr/bin/env perl
use strict; use warnings;
for my $f (@ARGV){
  local $/; open my $in,'<',$f or next; my $s=<$in>; close $in;
  # "…*.html", keep query/hash, make root-absolute, skip http/mailto/tel/#, case-insens
  $s =~ s/href="(?!https?:\/\/|mailto:|tel:|#)([^"#?]+)\.html([#?][^"]*)?"/'href="/'.($1=~s#^/*##r).'/'.($2//"").'"'/ige;
  # '…*.html'
  $s =~ s/href='(?!https?:\/\/|mailto:|tel:|#)([^'#?]+)\.html([#?][^']*)?'/"href=\"\/".($1=~s#^/*##r).\"\/\".($2\/\/\"\")."\""/ige;
  open my $out,'>',$f or next; print $out $s; close $out;
}
