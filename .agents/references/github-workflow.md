# GitHub workflow commands

The exact `gh` commands for the flow in `../rules/github.md`. Replace each `<placeholder>`. Write every title and body to a scratch file first.

## Issues and plans

```sh
gh issue create --title "<title>" --body-file <file> --label <label>
gh issue create --title "<title>" --body-file <file> --parent <parent-number>
gh issue edit <parent-number> --add-sub-issue <number>,<number>
gh issue edit <number> --milestone "<milestone>"
gh api repos/<owner>/<repo>/issues/<number>/dependencies/blocked_by -F issue_id=<blocking-issue-id>
gh issue develop <number> --checkout
```

The `issue_id` of a blocking issue is its REST `id`: `gh api repos/<owner>/<repo>/issues/<number> --jq .id`.

Set Priority and Effort with the GraphQL `setIssueFieldValue` mutation. Read the field and option IDs from `repository.issueFields`.

The project workflows add each issue and set its Status. Read the board with `gh project item-list <project-number> --owner <owner>`.

## Pull requests

```sh
gh pr create --title "<title>" --body-file <file> --assignee @me --label <label>
gh pr create --draft --title "<title>" --body-file <file>
gh pr ready <number>
gh pr comment <number> --body-file <file>
```

After the Claude review, run `/autofix-pr` on the PR branch. The Claude GitHub app must be on the repository.

## Blocked work

```sh
gh issue edit <number> --add-label needs-info
gh issue comment <number> --body-file <file>
```

## Repository setup

```sh
gh label create "<area>" --color c5def5 --description "Changes in the <area> area" --force
gh label create needs-info --color d93f0b --description "Waiting on the user" --force
for label in bug enhancement duplicate invalid wontfix question "good first issue" "help wanted"; do gh label delete "$label" --yes; done
gh repo edit <owner>/<repo> --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false --enable-auto-merge --delete-branch-on-merge
gh api -X PATCH repos/<owner>/<repo> -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=BLANK
gh project create --owner <owner> --title "<project>"
gh project link <project-number> --owner <owner> --repo <owner>/<repo>
gh repo edit <owner>/<repo> --enable-projects
```

The repository Projects feature must be on, or `gh repo view --json projectsV2` returns nothing for a linked project.

## Automation

- Project workflows: auto-add with the filter `is:issue is:open`, item added to Backlog, PR linked to In progress, reopened to Ready, closed or merged to Done.
- Also turn on auto-close issue, auto-archive for closed items, and auto-add sub-issues. A changed Status option breaks each workflow that uses it.
- Review gate: fail a `claude-code-action` job on a JSON verdict, and make that job a required check. A job after it sets In review on each issue that the PR closes.
- Triage: a workflow on new, edited, and reopened issues gives Claude only issue view and list commands, with no file tools. A shell step applies its JSON result.
- The schema returns fixed codes, and the shell step maps them to fixed comment text. No model text reaches a public comment.
- Triage uses `github_token` with only `issues: write` and `allowed_non_write_users`, so it can triage external issues. It fills only unset values.
- Project moves and the agent gate need a fine-grained project token secret. `GITHUB_TOKEN` cannot read org projects.

## Agents and merges

- The maintainer assigns a hosted agent (Copilot, Claude, or Codex) to a Ready issue. Effort guides the model choice in the assign dialog.
- The org Copilot policies must allow each partner agent. Hosted agents read `AGENTS.md` and set up with `.github/workflows/copilot-setup-steps.yml`.
- Agent gate: a workflow on `issues: assigned` checks each Bot assignee. When the issue is not Ready or has no Priority or Effort, it unassigns and comments.
- Otherwise the gate sets In progress, and the review gate and the project workflows do the other moves.
- Merge queue: run the required workflows on `merge_group`. Jobs that only fit PRs skip there, and a skipped required check passes.
- Squash merges: lint the PR title with commitlint in a required check, because the title becomes the commit header.
- Dependabot auto-merge: on PRs by `dependabot[bot]`, read `dependabot/fetch-metadata`. Run `gh pr merge --auto --squash` for npm updates that are not major.
