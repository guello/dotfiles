#!/bin/sh
#
# PreToolUse guardrail (Edit|Write|MultiEdit) that block writes to generated or
# auto-managed files under $HOME that would be silently overwritten, and redirect
# edits made through symlinks to their source.
# Exit 2 blocks. Any other path or missing jq fails open (exit 0).
# macOS-only and no-op without a file path.

set -u

case ":$PATH:" in
  *:/opt/homebrew/bin:*) ;;
  *) PATH="/opt/homebrew/bin:/usr/local/bin:$PATH" ;;
esac

input="$(cat)"
fp="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"
[ -n "$fp" ] || exit 0

case "$fp" in
  /*) abs="$fp" ;;
  *) abs="$PWD/$fp" ;;
esac

deny() {
  printf 'Blocked by guard-managed-files: %s\n' "$1" >&2
  exit 2
}

case "$abs" in
  "$HOME"/.git/hooks/*)
    deny "$HOME/.git/hooks/* is unused. This repo's hooks run from .config/git/hooks/, edit them there instead."
    ;;
  "$HOME"/.claude/skills/* | "$HOME"/.codex/AGENTS.md | "$HOME"/.pi/agent/AGENTS.md)
    deny "$abs resolves through a symlink to ~/.agents/. Edit the source under ~/.agents/ instead."
    ;;
  "$HOME"/.claude/rules | "$HOME"/.claude/rules/*)
    deny "This setup keeps no ~/.claude/rules folder. Place global Claude-only lines in ~/.claude/CLAUDE.md after its @~/.agents/AGENTS.md import. Shared rules are in ~/.agents/rules/ and must be routed from ~/.agents/AGENTS.md."
    ;;
esac

exit 0
