#!/bin/sh
#
# PostToolUse guardrail (Edit|Write|MultiEdit): measure an agentic document
# right after it is written and report budget breaches back to the agent.
# Runs count_tokens.py from the sync-agents skill, which infers the file's
# role (entrypoint, rule, skill body, reference, spec, agent definition,
# memory index) and applies the target and cap from context-budgets.md plus
# the line rules. A cap breach exits 2 so the agent reads the report and
# fixes the file before moving on. A target breach prints a warning and
# exits 0. Non-agentic paths, manager-owned skill folders, a missing
# python3 or script, and any probe failure fail open (exit 0).
# Only persistent files are measured: plans, temporary folders, files that
# Git ignores, and files outside a work tree are skipped. Claude memory is
# gitignored but loads at startup, so it stays measured.

set -u

case ":$PATH:" in
  *:/opt/homebrew/bin:*) ;;
  *) PATH="/opt/homebrew/bin:/usr/local/bin:$PATH" ;;
esac

script="$HOME/.agents/skills/sync-agents/scripts/count_tokens.py"
[ -f "$script" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
fp="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"
[ -n "$fp" ] || exit 0

case "$fp" in
  /*) abs="$fp" ;;
  *) abs="$PWD/$fp" ;;
esac
[ -f "$abs" ] || exit 0

case "$abs" in
  */.system/* | */.claude/jobs/* | */.claude/worktrees/* | */.claude/projects/*/tool-results/*) exit 0 ;;
  */.agents/plans/* | */.claude/plans/* | /tmp/* | /private/tmp/* | /var/folders/* | /private/var/folders/*) exit 0 ;;
  */AGENTS.md | */CLAUDE.md | */copilot-instructions.md | */MEMORY.md | */SKILL.md) ;;
  */.agents/*.md | */.claude/*.md | */.codex/*.md | */.copilot/*.md | */.github/instructions/*.md | */.cursor/*.md | */.codex/agents/*.toml) ;;
  *) exit 0 ;;
esac

case "$abs" in
  */.claude/projects/*/memory/*) ;;
  *)
    command -v git >/dev/null 2>&1 || exit 0
    dir="${abs%/*}"
    [ "$(git -C "$dir" rev-parse --is-inside-work-tree 2>/dev/null)" = true ] || exit 0
    git -C "$dir" check-ignore -q -- "$abs" 2>/dev/null && exit 0
    ;;
esac

report="$(python3 "$script" "$abs" --hook 2>/dev/null)"
status=$?
[ "$status" -le 1 ] || exit 0
[ -n "$report" ] || exit 0

if [ "$status" -eq 1 ]; then
  printf 'Blocked by guard-context-budgets: the file exceeds a hard cap from context-budgets.md. Split, scope, or move detail to a reference before continuing.\n%s\n' "$report" >&2
  exit 2
fi

printf 'guard-context-budgets: above target, aim lower before handing off.\n%s\n' "$report" >&2
exit 0
