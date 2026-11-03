# Engineering workflow and verification

Conditional workflow routed from `../AGENTS.md`. Read before coding, file changes, reviews, commands, or delegation; apply the sections relevant to the task.

## Before editing

- Run `git status --short -uall` before changes or review; preserve modified and untracked files outside the requested scope.
- Follow existing style where repository instructions and configuration are silent.
- Prefer no change, standard library, native features, installed dependencies, then new code.
- Build only what is required: no speculative abstractions, options, or compatibility layers.
- Search shared layers before adding a helper, constant, or hook; promote only for a second consumer.
- Leave no explanatory comments, section markers, or TODOs; add JSDoc only where adjacent code already uses it.
- `.git/local/` (`$(git rev-parse --git-common-dir)/local`) holds user-owned untracked files; never commit, delete, or create it unasked.

## Surgical diffs

- Touch only required lines; a rename changes identifiers only, never comments, whitespace, or adjacent code.
- Remove only newly dead code and flag pre-existing dead code; fix an adjacent bug only when it intersects the change.
- Re-read a file the user edited before continuing; their edits are locked intent.
- Regenerate artifacts with their tool; update docs when behavior, commands, or paths change.

## Code safety

- Use types for impossible states; guard I/O, timeouts, cancellation, and races.
- Give async UI loading, empty, and error states.

## Local environment and toolchain

- The host is macOS on Apple Silicon with Homebrew at `/opt/homebrew`; the editor and terminal are VS Code and Ghostty.
- `$HOME` is the dotfiles repository.
- Project code is in `~/Developer/@<owner>/<repo>`, scratch in `@<owner>/.tmp`, and archived or obsolete repositories in `@<owner>/.archive`.
- `profile`, `plugin`, `brew`, `mas`, `lts`, `deps`, and `dotfiles` are zsh plugin functions under `~/.zsh`, not binaries.
- Runtimes come only from the `nodenv`, `pyenv`, and `rbenv` shims; never add another version manager.
- The default Node package manager is pnpm through Corepack; the project's lockfile always wins.
- Run the repository's configured formatter; otherwise use oxfmt for JS, TS, CSS, and JSON, or shfmt and shellcheck for shell.
- For other files, follow `.editorconfig`.

## Verification

- Add regression coverage before fixing a bug; get a green baseline before a refactor.
- Run types, lint, tests, then behavior; report the commands and separate new failures from baseline noise.
- After fixing a bug, grep for the same shape and answer for every match: fix it, safe to leave and why, or ask.
- For UI, verify with browser automation and screenshots per `../rules/browser.md`; static checks cannot prove layout or interaction.

## Delegation

- Delegate bounded, independent, read-only tasks to the configured explorers and reviewers, never nested, at most 3 concurrent.
- Run output-heavy commands (full test suites, builds, log searches) in a general-purpose subagent that returns failures and a short summary. Run quick checks directly.
- Give each delegate a root, a scope, the evidence to return, and a stop condition.
- The primary owns writes, architecture, synthesis, and verification.
- Parallel writers need explicit permission, isolated worktrees, and disjoint files.

## Reviewer protocol

- After multi-file or behavior changes, run a reviewer subagent for correctness, security, spec compliance, and conventions.
- Pass the complete diff when the reviewer's tools cannot read the Git history.
- Every finding cites `file:line` with a failure scenario; confirm each one before acting on it.
- Stop after two review rounds and hand off unresolved items.

## Running services

- Before starting a dev server or service, check for one already running: a listening port, an open terminal, an open tab. Reuse it.
- On a port-in-use error, identify the listener and verify it is the intended app before testing; never kill it or switch ports.
- Start a new instance only when no running one can serve the change, and ask before restarting one you did not start.

## Evidence layers

- Source, CI, package contents, installed runtime, release assets, registry, and deployed state are separate layers; one never implies another.
- Report each layer checked and name the rest as gaps before calling anything released, published, installed, or done.

## Commit decision

- Read the branch history first: `git log --oneline <base>..` on a PR branch, else `git log --oneline @{upstream}..`.
- When the repository merges PRs by squash, skip the fold: push each fix as a new commit, and keep the PR title a Conventional Commit header.
- Avoid new commits. A PR holds only the essential commits that compose its final result, so that it merges as is with no history change.
- Fold each fix, adjustment, and review follow-up into the commit that it changes: `git commit --fixup=<sha>`, then `git rebase -i --autosquash <base>`.
- Make a new commit only for a standalone change that must stay apart in the history.
- Name each fold target by its short hash and subject.
- Mixed concerns get the fewest commits. Split them only when they must stay apart.
- The fold also applies to pushed commits on an unmerged PR branch that you own. Push the rewrite with `git push --force-with-lease`.
- Never rewrite the default branch, a merged branch, or a branch that another person also pushes to. For those, propose a new commit.
- When the work addresses a GitHub issue, reference it in the footer (`Closes #12`, `Fixes #12` for bugs, `Refs #12` for partial work) per `../rules/github.md`.
