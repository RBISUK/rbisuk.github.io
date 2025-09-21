#!/usr/bin/env bash
set -Eeuo pipefail; IFS=$'\n\t'
die(){ echo "❌ $*" >&2; exit 1; }
bak(){ local f="$1"; [[ -f "$f" ]] || die "No such file: $f"; local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"; cp -p "$f" "${f}.bak.${ts}"; echo "🛟 Backup -> ${f}.bak.${ts}"; }
