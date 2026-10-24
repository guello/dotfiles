#!/bin/sh
#
# PreToolUse guardrail (Edit|Write|MultiEdit|Bash): enforce the AGENTS.md
# committed-writing and portability hard boundaries at write time. Blocks a
# tool call that ADDS an em or en dash, or a machine-specific /Users/<name>
# path, to a file inside a git work tree that is not gitignored (the
# "committed file" scope; scratch and generated paths are ignored, so they
# pass). In any work tree other than the $HOME dotfiles repository it also
# blocks adding a home-anchored reference to the user's agent tree or
# projects (~/.agents, ~/.claude, ~/.codex, ~/.copilot, ~/Developer, with ~
# spelled as ~, $HOME, or ${HOME}): a repository file must not depend on one
# machine's dotfiles or user-level skills. Pre-existing occurrences are
# allowed: only a net increase over the replaced text (Edit/MultiEdit) or the
# current file content (Write) blocks. /Users/Shared is a standard macOS path
# and never blocks.
#
# Simplified Technical English (writing.md): committed *.md, *.mdx, and *.txt
# prose, and the text of git commit, git tag, and gh pr|issue|release
# create|edit|comment|review commands, block on net-new semicolons,
# contractions, and sentences over 25 words. Command text also blocks on em
# or en dashes, session links, Claude-Session trailers, and AI co-author or
# "Generated with" lines. Code, URLs, quotations, headings, and tables are
# skipped. The installed simplified-technical-english checker adds advisory
# findings as additionalContext and never blocks.
# Exit 2 blocks; missing jq/git/python3 or any probe failure fails open (exit 0).

set -u

case ":$PATH:" in
  *:/opt/homebrew/bin:*) ;;
  *) PATH="/opt/homebrew/bin:/usr/local/bin:$PATH" ;;
esac

input="$(cat)"

ste() {
  command -v python3 >/dev/null 2>&1 || return 0
  tmp="$(mktemp "${TMPDIR:-/tmp}/guard-writing.XXXXXX" 2>/dev/null)" || return 0
  printf '%s' "$input" >"$tmp"
  python3 -I /dev/fd/3 "$tmp" 3<<'PY'
import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

RSQ, LDQ, RDQ, EN, EM = (chr(c) for c in (0x2019, 0x201C, 0x201D, 0x2013, 0x2014))
APOS = "['" + RSQ + "]"
PROSE_EXT = (".md", ".mdx", ".txt")
CHECKER = Path.home() / ".agents/skills/simplified-technical-english/scripts/ste_check.py"
WORDISH = re.compile("[A-Za-z0-9'&/" + RSQ + "-]+")
CONTRACTION = re.compile(
    r"\b\w+n" + APOS + r"t\b|\b\w+" + APOS + r"(?:re|ll|ve|m|d)\b|"
    r"\b(?:it|that|there|what|let|who|here|he|she)" + APOS + r"s\b",
    re.IGNORECASE,
)
SESSION_LINK = re.compile(r"claude\.ai/code/session_\w+")
SESSION_TRAILER = re.compile(r"^\s*Claude-Session:", re.MULTILINE)
AI_COAUTHOR = re.compile(
    r"^\s*Co-authored-by:.*\b(claude|anthropic|codex|openai|copilot|cursor|gemini)\b",
    re.IGNORECASE | re.MULTILINE,
)
GENERATED = re.compile(r"^.*\bGenerated (?:with|by) \[?(?:Claude|Codex|Copilot|Cursor|Gemini)", re.IGNORECASE | re.MULTILINE)
DASH = re.compile("[" + EN + EM + "]")
QUOTED = re.compile(r"\"[^\"]*\"|" + LDQ + "[^" + RDQ + "]*" + RDQ)
HEREDOC = re.compile(r"<<-?[ \t]*(['\"]?)([A-Za-z_]\w*)\1([^\n]*)\n(.*?)\n[ \t]*\2[ \t]*(?=\n|$)", re.DOTALL)
CC_PREFIX = re.compile(r"\A[a-z]+(?:\([^)]*\))?!?:\s+")


def prose_units(text):
    text = re.sub(r"\A---\n.*?\n---\n", "", text, flags=re.DOTALL)
    text = re.sub(r"<!--.*?-->", " ", text, flags=re.DOTALL)
    units, buf, fence, last_item = [], [], None, False

    def flush():
        if buf:
            units.append(" ".join(buf))
            buf.clear()

    for line in text.splitlines():
        s = line.strip()
        if fence:
            if s.startswith(fence):
                fence = None
            continue
        m = re.match(r"(`{3,}|~{3,})", s)
        if m:
            flush()
            fence, last_item = m.group(1), False
            continue
        if not s or s.startswith(("#", "|", ">", "<", "import ", "export ")):
            flush()
            last_item = False
            continue
        item = re.match(r"(?:[-*+]|\d+[.)])\s+(.*)", s)
        if item:
            flush()
            units.append(item.group(1))
            last_item = True
            continue
        if last_item and line[:1] in (" ", "\t") and not buf:
            units[-1] += " " + s
            continue
        last_item = False
        buf.append(s)
    flush()
    return units


def clean(unit):
    unit = re.sub(r"`[^`]*`", " CODE ", unit)
    unit = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", unit)
    unit = re.sub(r"<?https?://\S+>?", " URL ", unit)
    return QUOTED.sub(" QUOTED ", unit)


def sentences(text):
    out = []
    for unit in prose_units(text):
        for part in re.split(r"(?<=[.!?:])\s+", clean(unit)):
            part = " ".join(part.split())
            if part and WORDISH.search(part):
                out.append(part)
    return out


def count_words(sentence):
    s = re.sub(r"\([^)]*\)", " PAREN ", sentence)
    s = re.sub(r"\*\*|\*|__|_|#+", " ", s)
    return len(WORDISH.findall(s))


def ste_issues(new_sents):
    issues = []
    for s in new_sents:
        head = s if len(s) <= 70 else s[:67] + "..."
        if ";" in s:
            issues.append(f'semicolon (STE 8.1), write two sentences: "{head}"')
        m = CONTRACTION.search(s)
        if m:
            issues.append(f'contraction "{m.group(0)}" (STE 4.2), write the full words: "{head}"')
        n = count_words(s)
        if n > 25:
            issues.append(f'sentence has {n} words, max 25 (STE 6.3): "{head}"')
    return issues


def advisory(new_sents):
    if not new_sents or not CHECKER.is_file():
        return ""
    try:
        res = subprocess.run(
            [sys.executable, "-I", str(CHECKER), "--mode", "mixed"],
            input="\n\n".join(new_sents), capture_output=True, text=True, timeout=3,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    findings, words, in_words = [], [], False
    for line in res.stdout.splitlines():
        m = re.match(r"(?:ERROR|WARNING)\s+\S+\s+(.*)", line)
        if m and m.group(1) not in findings:
            findings.append(m.group(1))
            continue
        if line.startswith("CHECK"):
            in_words = True
            continue
        if in_words and "Each must be" in line:
            continue
        if in_words and line.startswith("        "):
            words.extend(w.strip() for w in line.split(",") if w.strip())
            continue
        in_words = False
    parts = findings[:12]
    if words:
        parts.append("Not in the STE word list (each must be a technical name or technical verb): " + ", ".join(words[:20]))
    return "\n".join(parts)


def emit(issues, advice, label):
    if issues:
        shown = "\n".join(f"- {i}" for i in issues[:10])
        sys.stderr.write(
            f"Blocked by guard-committed-writing: {label} breaks Simplified Technical English (writing.md).\n{shown}\n"
        )
        sys.exit(2)
    if advice:
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": f"Advisory STE findings for {label} (not blocking):\n{advice}",
        }}))
    sys.exit(0)


def file_mode(ti):
    fp = ti.get("file_path") or ti.get("path") or ""
    if not fp.endswith(PROSE_EXT):
        sys.exit(0)
    p = Path(fp)
    old = p.read_text(encoding="utf-8") if p.is_file() else ""
    if "content" in ti or "file_text" in ti:
        new = ti.get("content") or ti.get("file_text") or ""
    else:
        edits = ti.get("edits") or [{
            "old_string": ti.get("old_string", ti.get("old_str")),
            "new_string": ti.get("new_string", ti.get("new_str")),
            "replace_all": ti.get("replace_all"),
        }]
        new = old
        for e in edits:
            o, n = e.get("old_string") or "", e.get("new_string") or ""
            if not o or o not in new:
                sys.exit(0)
            new = new.replace(o, n) if e.get("replace_all") else new.replace(o, n, 1)
    seen = set(sentences(old))
    fresh = [s for s in sentences(new) if s not in seen]
    emit(ste_issues(fresh), advisory(fresh), p.name)


def resolve(val, is_file, bodies, cwd):
    m = re.search(r"__HD(\d+)__", val)
    if m:
        return bodies[int(m.group(1))]
    if is_file and "$(" not in val:
        val = os.path.expandvars(val)
    if "$" in val:
        return None
    if not is_file:
        return val
    if val == "-":
        return bodies[0] if bodies else None
    p = Path(val) if val.startswith("/") else Path(cwd) / val
    if not p.is_file() or p.stat().st_size > 200_000:
        return None
    return p.read_text(encoding="utf-8", errors="replace")


def collect(args, text_flags, file_flags, git):
    out, i = [], 0
    while i < len(args):
        a, val, is_file = args[i], None, False
        if a.startswith("--") and "=" in a:
            k, v = a.split("=", 1)
            if k in text_flags or k in file_flags:
                val, is_file = v, k in file_flags
        elif a in text_flags or a in file_flags:
            if i + 1 < len(args):
                val, is_file = args[i + 1], a in file_flags
                i += 1
        elif git and re.fullmatch(r"-[a-zA-Z]+[mF]", a) and i + 1 < len(args):
            val, is_file = args[i + 1], a.endswith("F")
            i += 1
        elif git and a.startswith(("-m", "-F")) and len(a) > 2:
            val, is_file = a[2:], a.startswith("-F")
        if val is not None:
            out.append((val, is_file))
        i += 1
    return out


def command_mode(cmd, cwd):
    bodies = []

    def stash(m):
        bodies.append(m.group(4))
        return f"__HD{len(bodies) - 1}__{m.group(3)}"

    lex = shlex.shlex(HEREDOC.sub(stash, cmd), posix=True, punctuation_chars=";&|")
    lex.whitespace_split = True
    try:
        toks = list(lex)
    except ValueError:
        sys.exit(0)
    segs, cur = [], []
    for t in toks:
        if t and set(t) <= set(";&|"):
            segs.append(cur)
            cur = []
            continue
        cur.append(t)
    segs.append(cur)

    texts = []
    for seg in segs:
        while seg and re.fullmatch(r"[A-Za-z_]\w*=.*", seg[0]):
            seg = seg[1:]
        if len(seg) > 1 and seg[0] == "git":
            i = 1
            while i < len(seg) and seg[i].startswith("-"):
                i += 2 if seg[i] in ("-C", "-c", "--git-dir", "--work-tree") else 1
            if i < len(seg) and seg[i] in ("commit", "tag"):
                texts += collect(seg[i + 1:], ("-m", "--message"), ("-F", "--file"), True)
        if len(seg) > 2 and seg[0] == "gh" and seg[1] in ("pr", "issue", "release") \
                and seg[2] in ("create", "edit", "comment", "review"):
            texts += collect(seg[3:], ("-t", "--title", "-b", "--body", "-n", "--notes"),
                             ("-F", "--body-file", "--notes-file"), False)

    resolved = [t for t in (resolve(v, f, bodies, cwd) for v, f in texts) if t]
    if not resolved:
        sys.exit(0)
    raw = "\n\n".join(resolved)
    issues = []
    if DASH.search(raw):
        issues.append("em or en dash (AGENTS.md hard boundary): use a period, comma, colon, hyphen, or parentheses")
    if SESSION_LINK.search(raw) or SESSION_TRAILER.search(raw):
        issues.append("session link or Claude-Session trailer: remove it (AGENTS.md attribution rule)")
    if AI_COAUTHOR.search(raw) or GENERATED.search(raw):
        issues.append("AI co-author or Generated-with line: remove it (AGENTS.md attribution rule)")
    prose = "\n\n".join(CC_PREFIX.sub("", t, count=1) for t in resolved)
    fresh = sentences(prose)
    emit(issues + ste_issues(fresh), advisory(fresh), "this commit or GitHub text")


def main():
    data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    ti = data.get("tool_input") or {}
    if isinstance(ti, str):
        ti = json.loads(ti)
    cmd = ti.get("command")
    if cmd:
        command_mode(cmd, data.get("cwd") or ".")
    file_mode(ti)


try:
    main()
except SystemExit:
    raise
except Exception:
    sys.exit(0)
PY
  status=$?
  rm -f "$tmp"
  [ "$status" -eq 2 ] && exit 2
  return 0
}

cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
case "$cmd" in
  "") ;;
  *git*" commit"* | *git*" tag "* | *"gh pr "* | *"gh issue "* | *"gh release "*)
    ste
    exit 0
    ;;
  *) exit 0 ;;
esac

fp="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"
[ -n "$fp" ] || exit 0

case "$fp" in
  /*) abs="$fp" ;;
  *) abs="$PWD/$fp" ;;
esac

dir="$(dirname "$abs")"
while [ ! -d "$dir" ] && [ "$dir" != "/" ]; do dir="$(dirname "$dir")"; done
git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git -C "$dir" check-ignore -q "$abs" 2>/dev/null && exit 0
top="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)"

content="$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.file_text // empty' 2>/dev/null)"
if [ -n "$content" ]; then
  new="$content"
  old="$(cat "$abs" 2>/dev/null || true)"
else
  new="$(printf '%s' "$input" | jq -r '(.tool_input.new_string // .tool_input.new_str // empty), ((.tool_input.edits // [])[].new_string // empty)' 2>/dev/null)"
  old="$(printf '%s' "$input" | jq -r '(.tool_input.old_string // .tool_input.old_str // empty), ((.tool_input.edits // [])[].old_string // empty)' 2>/dev/null)"
fi
[ -n "$new" ] || exit 0

deny() {
  printf 'Blocked by guard-committed-writing: %s\n' "$1" >&2
  exit 2
}

em="$(printf '\342\200\224')"
en="$(printf '\342\200\223')"

count_dashes() { printf '%s' "$1" | grep -o -F -e "$em" -e "$en" 2>/dev/null | wc -l | tr -d ' '; }
count_users_paths() { printf '%s' "$1" | grep -oE '/Users/[A-Za-z0-9._-]+' 2>/dev/null | grep -cv '^/Users/Shared$'; }
# shellcheck disable=SC2016
count_home_refs() { printf '%s' "$1" | grep -oE '(~|\$HOME|\$\{HOME\})/(\.agents|\.claude|\.codex|\.copilot|Developer)(/|[^A-Za-z0-9_.-]|$)' 2>/dev/null | wc -l | tr -d ' '; }

[ "$(count_dashes "$new")" -gt "$(count_dashes "$old")" ] &&
  deny "this edit adds an em or en dash to a committed file (AGENTS.md hard boundary). Rewrite with a period, comma, colon, hyphen, or parentheses."

[ "$(count_users_paths "$new")" -gt "$(count_users_paths "$old")" ] &&
  deny "this edit adds a machine-specific /Users/<name> path to a committed file (AGENTS.md hard boundary). Use \$HOME, ~, \$HOMEBREW_PREFIX, \$XDG_*, or a repo-relative path."

[ -n "$top" ] && [ "$top" != "$HOME" ] && [ "$(count_home_refs "$new")" -gt "$(count_home_refs "$old")" ] &&
  deny "this edit adds a reference to the user's agent tree or projects (~/.agents, ~/.claude, ~/.codex, ~/.copilot, ~/Developer) to a file in a project repository (AGENTS.md hard boundary). A repository depends only on what it contains; name a user-level procedure by its skill or command, never by path."

case "$abs" in
  *.md | *.mdx | *.txt) ste ;;
esac

exit 0
