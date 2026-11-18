# Engineering workflow and verification

Read before coding, file changes, reviews, commands, or delegation. Apply the sections relevant to the task.

## Before editing

- Run `git status --short -uall` before changes or review. Preserve modified and untracked files outside the requested scope.
- Follow the existing style when the repository instructions and configuration are missing or incomplete.
- Run the repository's configured formatter. Otherwise use oxfmt for JS, TS, CSS, and JSON, shfmt and shellcheck for shell, and `.editorconfig` for other files.
- Prefer no changes, standard libraries, and native features. Avoid new code, abstractions, or dependencies unless the task requires it.
- Build only what is required: avoid speculative abstractions, options, or compatibility layers.
- Search the shared layers before adding a helper, constant, or hook. Promote only for a second consumer.
- Leave no explanatory comments, section markers, or TODOs. Add JSDoc only where adjacent code already uses it.

## Surgical diffs

- Touch only the required lines. A rename changes the identifiers only, not the comments, whitespaces, or adjacent code.
- Remove added dead code and flag pre-existing one. Fix an adjacent bug only when it intersects the change.
- Re-read a file the user edited before continuing: their edits are locked intent.
- Regenerate artifacts with their tool. Update the docs when behaviors, commands, or paths change.

## Code safety

- Use types for impossible states. Guard I/O, timeouts, cancellation, and races.
- Give async UI loading, empty, and error states.

## Verification

- Add regression coverage before fixing a bug. Get a green baseline before a refactor.
- Run types, lint, and tests, then behavior. Report the commands and separate new failures from baseline noise.
- After fixing a bug, grep for the same shape and answer for every match: fix it, safe to leave and why, or ask.
- When a mistake occurs a second time, propose a lint rule, type, test, or hook that catches it.
- Keep a prose rule or a memory entry only for a judgment that no check can catch.
- For UI, verify with browser automation and screenshots per `browser.md`. Static checks cannot prove layout or interaction.

## Delegation

- Delegate bounded, independent, read-only tasks to the configured explorers and reviewers.
- Run output-heavy commands (full test suites, builds, log searches) in a general-purpose subagent that returns failures and a short summary. Run quick checks directly.
- Give each delegate a root, scope, the evidence to return, and a stop condition.
- The primary agent owns writes, architecture, synthesis, and verification.
- Parallel writers need explicit permission, isolated worktrees, and disjoint files.

## Reviewer protocol

- After multi-file or behavior changes, run a reviewer subagent for correctness, security, spec compliance, and conventions.
- Pass the complete diff when the reviewer's tools cannot read the Git history.
- Every finding must cite `file:line` with a failure scenario. Confirm each one before acting on it.
- Stop after two review rounds and hand off unresolved items.
- In the final report, name the most important changes that need a human read.
- A human read is always necessary for auth, migrations, deletes, secrets, payments, and public API, even after a clean agent review.

## Running services

- Before starting a dev server or service, check and reuse the ones already running: listening ports, open terminals, open tabs.
- On a port-in-use error, identify the listener and verify it is the intended app before testing. Never kill it or switch ports without verifying or asking.
- Start a new instance only when no running one can serve the change. Ask before restarting one you did not start.

## Evidence layers

- Source, CI, merge, package contents, installed runtime, release assets, registry, deployed state, and rendered screens are separate layers. One never implies another.
- Report each layer checked and name the rest as gaps before calling anything released, published, installed, or done.
- For UI work, done means that the named screens show the change when the app runs.

## Commit decision

- Read the branch history first: `git log --oneline <base>..` on a PR branch, else `git log --oneline @{upstream}..`.
- When the repository merges PRs by squash, skip the fold: push each fix as a new commit, and keep the PR title a Conventional Commit header.
- Avoid new commits. A PR holds only the essential commits that compose its final result, so that it merges as is with no history change.
- Fold each fix, adjustment, and review follow-up into the commit that it changes: `git commit --fixup=<sha>`, then `git rebase -i --autosquash <base>`.
- Make a new commit only for a standalone change that must stay apart in the history.
- Name each fold target by its short hash and subject.
- Mixed concerns get the fewest commits. Split them only when they must stay apart.
- The fold also applies to pushed commits on an unmerged PR branch that you own. Push the rewrite with `git push --force-with-lease`.
- Never rewrite the default branch, a merged branch, or a branch that another person also pushes to. For those, propose a new commit instead.
- When the work addresses a GitHub issue, reference it in the footer (`Closes #12`, `Fixes #12` for bugs, `Refs #12` for partial work) per `github.md`.
