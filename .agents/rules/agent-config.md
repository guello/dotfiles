# Agent configuration

Applies only in the `$HOME` repository. Loader detail: `~/.agents/references/dotfiles-loaders.md`.

## Sources

- Edit shared `.agents` sources. Provider entrypoints are relative links, except `.claude/CLAUDE.md`.
- Never edit through a link or copy shared instructions into a provider tree.

## Loader routes

- `.codex/AGENTS.md`, `.pi/agent/AGENTS.md`, `.copilot/copilot-instructions.md`, and `.config/opencode/AGENTS.md` link to `.agents/AGENTS.md`.
- `.claude/CLAUDE.md` is a regular file: `@~/.agents/AGENTS.md` on the first line, then the Claude-only lines.
- Never list `.agents/AGENTS.md` in `claudeMdExcludes`: the exclude also drops the import.
- Repository `CLAUDE.md` and `.claude/rules` cases: "Standard project wiring" in `.agents/skills/sync-agents/references/agentic-architecture.md`.
- Give each rule and reference its own row in the `.agents/AGENTS.md` routing table, even when another rule points to it.
- Codex-only lines go in `developer_instructions` in `.codex/settings.toml`. Pi-only lines go in `.pi/agent/APPEND_SYSTEM.md`.
- Copilot runs only in VS Code. It loads `.copilot/copilot-instructions.md`, and `chat.useClaudeMdFile` is off to keep Claude-only lines out.
- OpenCode is dormant. Keep `.config/opencode` unchanged and add no adapter for it.

## Tool assets

- Codex, Pi, and VS Code read `.agents/skills` natively. Claude reads it through the `.claude/skills` link.
- Never copy a skill into a provider tree. A Claude-only skill becomes a plugin in `.claude/mods`.
- Keep native assets in `.claude/{agents,commands,mods,output-styles}`, `.codex/{agents,skills,hooks.json}`, `.copilot/*.json`, `.config/opencode`, and `.pi/agent`.

## Provider configuration

- Track Copilot defaults and hooks in `.copilot/settings.json`, and language servers in `.copilot/lsp-config.json`.
- Keep the user's Copilot model, effort, and interface choices; check every key against `copilot help config`.
- Keep Copilot private state CLI-managed; never duplicate skills into `.copilot/skills`.
- Track Codex defaults in `.codex/settings.toml`; keep `.codex/config.toml` private and mode `600`.
- Track portable OpenCode defaults in `.config/opencode/opencode.json`; use `{env:NAME}` for secrets, never plaintext.
- Track Pi defaults in `.pi/agent/settings.json` and extensions in `.pi/agent/extensions`; ignore state.
- Ongoing shell startup may repair user-owned state but never invokes `sudo`.

## Hooks, memory, and statuslines

- `.agents/hooks` holds agent, not Git, hooks; register each script by its `$HOME/.agents/hooks` path.
- Register shared hooks in `.claude/settings.json`, `.codex/hooks.json`, and `.copilot/settings.json`; a hook reads both Claude and Copilot field spellings.
- Treat write guards as best effort; a `Bash` redirect reaches disk unchecked.
- Claude auto memory writes machine-local notes under `~/.claude/projects/<project>/memory/`. Keep the directory untracked and run `/compact-memory` for auto-memory reviews.
- Update `.claude/{statusline.sh,subagent-statusline.sh}` and `statusline.schema.json` together.
- Keep statusline scripts Bash 3.2 compatible, expand possibly-empty arrays as `${arr[@]+"${arr[@]}"}`, and fail open per `shell.md`.

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
