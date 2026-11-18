#!/bin/sh
#
# Measure a Claude Code memory index for /compact-memory.
#
# Usage: verify-index.sh <memory-dir>
#
# Exit status: 1 on a cap, limit, long, or missing finding, 2 on bad usage,
# and 0 otherwise.

set -eu

TARGET=500
CAP=800
LINE_MAX=150
LINES_MAX=200
BYTES_MAX=25000
LC_ALL=en_US.UTF-8
export LC_ALL

dir="${1:-}"
dir="${dir%/}"
if [ -z "$dir" ] || [ ! -d "$dir" ]; then
  echo 'usage: verify-index.sh MEMORY_DIR' >&2
  exit 2
fi
index="$dir/MEMORY.md"
if [ ! -f "$index" ]; then
  echo "usage: no MEMORY.md in $dir" >&2
  exit 2
fi

chars="$(sed 's/  */ /g' "$index" | wc -m | tr -d ' ')"
tokens=$((chars / 4))
remainder=$((chars % 4))
if [ "$remainder" -eq 3 ] || { [ "$remainder" -eq 2 ] && [ $((tokens % 2)) -eq 1 ]; }; then
  tokens=$((tokens + 1))
fi
[ "$tokens" -ge 1 ] || tokens=1
lines="$(wc -l <"$index" | tr -d ' ')"
bytes="$(wc -c <"$index" | tr -d ' ')"
entries="$(grep -c '^- \[' "$index" || true)"
status=0

echo "index: $tokens tokens, $lines lines, $entries entries (target $TARGET, cap $CAP)"
if [ "$tokens" -gt "$CAP" ]; then
  echo "cap: $tokens > $CAP tokens"
  status=1
elif [ "$tokens" -gt "$TARGET" ]; then
  echo "target: $tokens > $TARGET tokens"
fi
if [ "$lines" -gt "$LINES_MAX" ] || [ "$bytes" -gt "$BYTES_MAX" ]; then
  echo "limit: $lines lines, $bytes bytes; Claude Code loads $LINES_MAX lines or 25KB"
  status=1
fi

n=0
while IFS= read -r line || [ -n "$line" ]; do
  n=$((n + 1))
  case "$line" in
    '- ['*) ;;
    *) continue ;;
  esac
  length="$(printf '%s' "$line" | wc -m | tr -d ' ')"
  if [ "$length" -gt "$LINE_MAX" ]; then
    echo "long: line $n, $length > $LINE_MAX characters"
    status=1
  fi
  target="$(printf '%s\n' "$line" | sed -n 's/^- \[[^]]*\](\([^)]*\)).*/\1/p')"
  if [ -n "$target" ] && [ ! -f "$dir/$target" ]; then
    echo "missing: line $n, $target"
    status=1
  fi
done <"$index"

find "$dir" -name '*.md' ! -path "$index" | sort | while IFS= read -r file; do
  relative="${file#"$dir"/}"
  if ! grep -qF "]($relative)" "$index"; then
    echo "unindexed: $relative"
  fi
done

exit "$status"
