@~/.agents/AGENTS.md

# Claude Code

Claude-only additions to the shared instructions.

## Delegation

- Workflow and orchestration stages never run Fable-class models, even with approval. When a Fable-class review is necessary, run it after the workflow as a standalone subagent.
- Ask the user before you start a standalone Fable subagent. A fork inherits the context and cannot change its model, so this rule does not apply there.

## Worktrees

- When a feature ships, remove its worktree in the same turn without asking first.
- At each status report and after each merge, list the worktrees and remove each stale or unused one.
- A worktree is stale or unused when its PR merged or closed, its lane ended, or no agent uses it.
- Before removal, stop each process that runs from the worktree, such as servers or watchers, by PID.
- Never stop a process by name pattern or that the user started.
- When a worktree contains uncommitted changes, report them and keep the worktree.
- Remove with `git worktree remove --force`, then run `git worktree prune`.

## Artifacts

- Before you create an artifact, list your artifacts to find one about the same or a related topic.
- If a related artifact exists, add your work to it on a new page. Do not change other pages.
- Create a new artifact only when no related artifact exists.
