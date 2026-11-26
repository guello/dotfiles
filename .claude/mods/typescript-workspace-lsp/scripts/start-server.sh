#!/usr/bin/env bash
#
# Start the language server that matches the TypeScript version of the workspace.
# - TypeScript 7 and later: tsc --lsp
# - TypeScript 6 and earlier: typescript-language-server
#
# Usage: start-server.sh --stdio

set -euo pipefail

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'typescript-workspace-lsp: %s not found, run "npm install -g %s"\n' "$1" "$2" >&2
    exit 127
  fi
}

dir="${CLAUDE_PROJECT_DIR:-$PWD}"
while :; do
  ts="$dir/node_modules/typescript"
  if [[ -f "$ts/package.json" ]]; then
    if [[ -f "$ts/lib/tsserver.js" ]]; then
      require typescript-language-server typescript-language-server
      exec typescript-language-server "$@"
    fi
    exec "$dir/node_modules/.bin/tsc" --lsp "$@"
  fi
  [[ "$dir" == / ]] && break
  dir="$(dirname "$dir")"
done

require tsc typescript
exec tsc --lsp "$@"
