# Agent configuration

Applies only in the `$HOME` repository.

## Sources

- Edit shared `.agents` sources. Provider entrypoints are relative links, except `.claude/CLAUDE.md`.
- Never edit through a link or copy shared instructions into a provider tree.

## Support levels

- Claude and Pi get full support. Keep their setup complete, and verify each change in the tool itself.
- Codex and OpenCode get support at a lower priority. Keep their instructions, skills, subagents, commands, and registered hooks working.
- Copilot only needs basic support to work with the VS Code chat.

## Loader routes

- `.codex/AGENTS.md`, `.config/opencode/AGENTS.md`, `.copilot/copilot-instructions.md`, and `.pi/agent/AGENTS.md` link to `.agents/AGENTS.md`.
- `.claude/CLAUDE.md` is a regular file with `@~/.agents/AGENTS.md` and additional Claude-only lines. Never list `.agents/AGENTS.md` in `claudeMdExcludes`: the exclude also drops the import.
- Codex-only instructions go in `developer_instructions` in `.codex/settings.toml`.
- OpenCode-only lines go in a file listed in `instructions` in `.config/opencode/opencode.json`.
- OpenCode V2 reads `.config/opencode/AGENTS.md`, then each `AGENTS.md` from the working directory up to `$HOME`.
- Pi-only lines go in `.pi/agent/APPEND_SYSTEM.md`.
- VS Code reads only `.copilot/copilot-instructions.md`.
- Give each rule and reference its own row in the `.agents/AGENTS.md` routing table, even when another rule points to it.

## Tool assets

- Codex, Pi, OpenCode, and VS Code read `.agents/skills` natively. Claude reads it through the `.claude/skills` link, which OpenCode also reads.
- Never copy a skill into a provider tree. A Claude-only skill becomes a plugin in `.claude/mods`.
- Keep native assets in `.claude/{agents,commands,mods,output-styles}`, `.codex/{agents,skills,hooks.json}`, `.config/opencode`, and `.pi/agent`.

## Provider configuration

- Track Codex defaults in `.codex/settings.toml`, the public layer that a system link exposes as `/etc/codex/config.toml`.
- Keep `.codex/config.toml` ignored and mode `600`. It holds private state, secrets, and complete private MCP definitions.
- Keep each Codex MCP transport and its secret headers in one effective layer.
- Homebrew installs OpenCode V2 from `anomalyco/tap/opencode-v2`.
- Track portable OpenCode defaults in `.config/opencode/opencode.json`; use `{env:NAME}` for secrets, never plaintext.
- Track `agents/` and `commands/` in `.config/opencode`, and allowlist `plugins/` in `.gitignore`.
- Track Pi defaults in `.pi/agent/settings.json` and extensions in `.pi/agent/extensions`; ignore state.
- Ongoing shell startup may repair user-owned state but never invokes `sudo`.

## Hooks

- `.agents/hooks` holds agent, not Git, hooks; register each script by its `$HOME/.agents/hooks` path.
- Register shared hooks in `.claude/settings.json` and `.codex/hooks.json`.
- Pi and OpenCode have no shell-hook registry. A shared hook runs there only through a Pi extension or an OpenCode plugin.
- Treat write guards as best effort; a `Bash` redirect reaches disk unchecked.

## Memory and statuslines

- Claude auto memory (`autoMemoryEnabled` in `.claude/settings.json`) writes machine-local notes under `~/.claude/projects/<project>/memory/`.
- The first 200 lines or 25KB of each `MEMORY.md` load every session, outside the tracked stack.
- Keep the memory directory untracked, and run `/compact-memory` for auto-memory reviews.
- `.claude/statusline.sh` and `.claude/subagent-statusline.sh` are allowlisted executable entrypoints wired in `.claude/settings.json`.
- Both read `$CLAUDE_STATUSLINE_CONFIG`, by default `.claude/statusline.json`. Update them and `statusline.schema.json` together.
- Keep statusline scripts Bash 3.2 compatible, expand possibly-empty arrays as `${arr[@]+"${arr[@]}"}`, and fail open per `../shell.md`.

## Instruction style and budgets

- Follow `.agents/skills/sync-agents/references/agentic-architecture.md` for YAML frontmatter and instruction style: one directive per line, trigger first.
- Write to the targets in `.agents/skills/sync-agents/references/context-budgets.md`; the cap is the failure line.
- `guard-context-budgets.sh` measures each persistent agentic write. It skips plans, temporary folders, and files that Git ignores, except Claude memory.
- Fix a reported breach before the next step.

## External skills

- External skills are untracked and listed in `.agents/.skill-lock.json`; untracked alone does not establish ownership.
- Never hand-edit external skill files or lock entries, including descriptions, scripts, and metadata.
- Install with `npx skills add <owner/repo> --skill <name> --global --yes`; update with `npx skills update -g <names...> --yes`.
- Never create a project-level `~/skills-lock.json`.

## Local skills and subagents

- Locally authored skills are allowlisted and tracked directly, outside the manager lock.
- Treat `.codex/skills/.system` as tool-owned and never move, track, or delete them.
- Keep Codex skill-path overrides in the single private `.codex/config.toml`, never split across public and private layers.
- Before installing a skill, check for duplicate names; enforce description budgets only on locally authored skills.
- Keep native subagents narrow, read-only by default, and aligned across provider `agents/` directories.
