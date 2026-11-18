---
description: >-
  Compact the Claude Code auto-memory index: merge and de-index settled MEMORY.md entries, shorten entries, fix stale facts, propose checks.
disable-model-invocation: true
---

# Compact the memory index

`MEMORY.md` loads into every session, so its size is the recurring cost of memory.

- Compacting edits index lines. It changes a memory file only to correct or merge it.
- A de-indexed file stays on disk, but a session may not find it, so de-index only what no current work needs.
- In this command, a hook is the text after the separator in an index line.

## Arguments

- No argument: classify, apply, and report.
- `--check`: classify and report the plan, write nothing.

## Operating contract

- Write only inside the memory directory: `MEMORY.md` and a memory file that needs a correction or a merge.
- When a memory file is a deletion candidate, name it and get explicit approval in the same turn. When no approval comes, de-index instead of deleting.
- Never move memory content into `MEMORY.md`.
- Rewrite `MEMORY.md` with one Write, not with line-by-line edits. The `guard-context-budgets` check blocks each Edit while the index is over its cap.
- Leave entries whose path starts with `team/` untouched because a teammate may depend on one.

## Locate

- Use the memory directory named in the system prompt's Memory section. `MEMORY.md` is at its root.
- When the prompt names no directory, stop and say so. Never guess another project's path.

## Budget

- Measure the index with `~/.claude/commands/compact-memory/verify-index.sh <memory-dir>`. Hold it at 500 tokens or fewer. 800 is the hard cap.
- Keep one entry per line in the existing `- [Title](file.md) <separator> <hook>` form. Each entry has about 100 characters and 150 at most.
- Claude Code loads only the first 200 lines or 25KB of the index.
- Merge and de-index first, because a line costs about 15 tokens before its hook. Shorten only the hooks that are genuinely long.

## Classify

Read `MEMORY.md`, list the directory with modification times, then assign every entry one action:

- Merge: two or more entries cover one subject. Fold the files into the best-described one, keep one index line, and delete the others only once approved.
- De-index: a settled decision now in rules, config, or code, or a finished feature or fixed bug. Delete the line, keep the file, and check its `description`.
- Correct: the current config or code contradicts the entry. Verify against the live file, then fix the memory file or propose its deletion.
- Shorten: a fact still operational whose hook says more than a session needs to decide whether to open the file. Cut it to that minimum.
- Promote: an entry that records a mechanical mistake that a lint rule, type, test, or hook can catch. Keep the line, and propose the check in the report.
- Keep: the user profile, active projects, constraints not derivable from a repository, and anything modified within the last month.
- When kept entries exceed the cap, merge them or report the cap as too low, never de-index.
- To date a memory file, prefer a date in its body, then its `modified` frontmatter field, then the file's modification time.

## Verify

- Run `verify-index.sh` again. Fix each `cap`, `limit`, `long`, and `missing` finding until the script exits 0.
- List each `unindexed` file in the report, and never re-add one.
- Confirm that nothing outside the memory directory changed.

## Report

- State the `index` line of `verify-index.sh` before and after.
- List the entries per action by name: merged, de-indexed, corrected, shortened, promoted, deleted.
- For each promoted entry, name the check, the repository, and the file that holds it.
- Close with the distance left to the 500-token target, and say plainly when merging and de-indexing cannot reach it.
