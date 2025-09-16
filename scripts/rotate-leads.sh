#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="logs"
ARCHIVE_DIR="$LOG_DIR/archive"
FILE="$LOG_DIR/leads.jsonl"
TS="$(date +%Y%m%d-%H%M%S)"
MAX_KEEP="${MAX_KEEP:-30}"        # how many archives to keep (uncompressed+compressed combined)
COMPRESS="${COMPRESS:-1}"         # 1 = gzip archives after rotate
MIN_SIZE_BYTES="${MIN_SIZE_BYTES:-10240}" # only rotate if file >= 10KB by default

mkdir -p "$ARCHIVE_DIR"
[[ -f "$FILE" ]] || : > "$FILE"

size=$(stat -c%s "$FILE" 2>/dev/null || echo 0)

if (( size < MIN_SIZE_BYTES )); then
  echo "ℹ️  Not rotating: $FILE size ${size}B < threshold ${MIN_SIZE_BYTES}B"
  exit 0
fi

ARCHIVE="$ARCHIVE_DIR/leads-$TS.jsonl"
mv "$FILE" "$ARCHIVE"
: > "$FILE"

if [[ "$COMPRESS" == "1" ]]; then
  gzip -f "$ARCHIVE"
  ARCHIVE="$ARCHIVE.gz"
fi

echo "✅ Rotated to $ARCHIVE"

# Prune older archives, keep newest MAX_KEEP
# Sort by mtime desc, skip first MAX_KEEP, delete the rest
mapfile -t old < <(ls -1t "$ARCHIVE_DIR"/leads-*.jsonl* 2>/dev/null | tail -n +$((MAX_KEEP+1)) || true)
if (( ${#old[@]} > 0 )); then
  printf "🧹 Pruning %d old archives...\n" "${#old[@]}"
  rm -f "${old[@]}"
fi
