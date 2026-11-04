# Tool loaders

Loader facts for the four tools this skill supports: Claude Code, Codex, Pi, and OpenCode. Read this file in Phase 1 to build the loader graph.

For any other tool, discover its loader from the repository configuration and the tool's docs, then verify it in the tool.

Never assume that one tool loads like another.

## Claude Code

- From 2.1.277, it reads `AGENTS.md` and `.claude/AGENTS.md` only where no `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` is in the folder or above it.
- It loads a nested `AGENTS.md` when it reads or mentions a file below it. A root `CLAUDE.md` stops these nested loads, also with `@AGENTS.md`.
- An `@path` import loads its target once. A symlink loads under the link path, so a nested load can add the same file again.
- `.claude/rules/*.md` loads at startup, or on a `paths` match, and does not stop the `AGENTS.md` load.
- It reads skills only from `.claude/skills`, so link that folder to `../.agents/skills`.
- Native assets: `.claude/settings.json` (hooks, permissions), `.claude/agents/`, `.claude/commands/`, and `.mcp.json`.
- User level: `~/.claude/CLAUDE.md` and `~/.claude/rules/`. It reads no user-level `AGENTS.md`.
- Evidence: an `InstructionsLoaded` hook log, or the `--debug` line `no CLAUDE.md found; AGENTS.md loaded`.

## Codex

- It reads one instruction file per folder from the git root to the working directory: `AGENTS.override.md`, else `AGENTS.md`.
- It reads a name from `project_doc_fallback_filenames` only where `AGENTS.md` is missing, so it skips a `CLAUDE.md` next to `AGENTS.md`.
- Codex-only additions go in `developer_instructions` in `config.toml`. `AGENTS.override.md` and `model_instructions_file` replace content instead.
- A project `.codex/config.toml` loads only after the user trusts the project.
- It reads skills from `.agents/skills` in each folder up to the repository root, plus `~/.agents/skills`, and follows symlinks.
- Native assets: `.codex/agents/*.toml`, `.codex/hooks.json`, `.codex/rules/`, and MCP servers in `config.toml`.
- User level: `~/.codex/AGENTS.md` and `~/.codex/config.toml`.

## Pi

- It reads the first of `AGENTS.override.md`, `AGENTS.md`, and `CLAUDE.md` in the agent folder, then in each folder from the working directory up.
- So it skips a `CLAUDE.md` next to `AGENTS.md`, and reads nothing below the working directory.
- Context files need no trust. The `--no-context-files` flag turns them off.
- Pi-only additions go in `APPEND_SYSTEM.md`. A trusted project `.pi/APPEND_SYSTEM.md` replaces the user file, and `SYSTEM.md` replaces the default prompt.
- It reads skills from `~/.agents/skills` always, and from project `.agents/skills` and `.pi/skills` after trust. It never reads `.claude/skills`.
- Native assets: `.pi/extensions/`, `.pi/prompts/`, and `.pi/settings.json`, all after trust. Hooks run through extensions.
- User level: `~/.pi/agent/` with `AGENTS.md`, `APPEND_SYSTEM.md`, `skills/`, `extensions/`, and `settings.json`.

## OpenCode

- V2 reads every `AGENTS.md` from the working directory up to `$HOME`, or to the project root outside `$HOME`, and a nested one on demand.
- It never reads `CLAUDE.md`. OpenCode-only additions go in a file listed in `instructions` in `opencode.json`, after the `AGENTS.md` files.
- Project config is `opencode.json` or `.opencode/opencode.json` in each folder up to the filesystem root. It needs no trust.
- It reads `skills` in `.claude`, `.agents`, and `.opencode` up to the project root, and in `~/.claude`, `~/.agents`, and `~/.config/opencode`.
- For one skill name, the last of these wins: `.claude`, `.agents`, `~/.config/opencode`, `.opencode`, and `skills` in `opencode.json`.
- Native assets: `.opencode/agents/*.md`, `.opencode/commands/*.md`, `.opencode/plugins/`, and MCP servers under `mcp` in `opencode.json`.
- Hooks run only in a plugin: a throw in `ctx.tool.hook("execute.before")` blocks the call. V1 plugins do not run in V2.
- User level: `~/.config/opencode/` with `AGENTS.md`, `opencode.json`, `agents/`, `commands/`, `plugins/`, and `skills/`.

## Cross-tool effects

- `AGENTS.md` reaches all four tools. Claude reads it only where no `CLAUDE.md` is in the folder or above it.
- A `CLAUDE.md` next to `AGENTS.md` reaches only Claude, and `.claude/rules` reaches only Claude.
- A nested `AGENTS.md` reaches OpenCode on demand, and Claude on demand where no `CLAUDE.md` is above it.
- Codex and Pi read a nested `AGENTS.md` only when the working directory is in its folder.
- `.agents/skills` reaches Codex, Pi, and OpenCode natively, and Claude through the `.claude/skills` link. OpenCode keeps one copy per name.
- Hooks, subagents, and commands are per tool. A shared hook script needs one registration for each tool, and a Pi extension or OpenCode plugin to call it.
