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

## Memory

- Keep each `MEMORY.md` entry to one line of about 100 characters, 150 at most.

## Artifacts

- Before you create an artifact, list your artifacts to find one about the same or a related topic.
- If a related artifact exists, add your work to it on a new page. Do not change other pages.
- Create a new artifact only when no related artifact exists.

## Mods

- Write mods in `~/.claude/mods/<name>/`. `CLAUDE_CODE_PLUGIN_DIRS` loads each mod in the folder in every session.
- Write the module in TypeScript as `hooks/register.ts` with `export const register: Register = on => {...}`. `tsc -p` checks every `$` call against the types written by the engine.
- Type `$` in helpers as `EngineInterface`. In tests, type `on` as `On` and `$` as `Engine` from `claude-code/testing`.
- The `{ text }` that a mod command returns reaches the model. For output that Claude must not read, return `{}` and use `$.ui.toast` or `$.ui.log`.
- Set `immediate: true` on a command that must run during a turn without blocking the model.
- Name each test file for the module it covers. Start it with `tier('user')` and place all its tests in one `describe` using that name.
- Place the setup shared by tests in `tests/fixtures/`, one export per file.
- In tests, stand-ins for `$` calls return `{ value }`. `$.command.run` needs `origin` and `presentation`.
- Keep the root `tsconfig.json` and add no `.gitignore`. The engine ignores `.claude-plugin/types/` by itself.
- Before shipping a mod, run `tsc -p`, `claude plugin validate`, and `claude plugin test`.
