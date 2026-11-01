# Project scaffold

The procedure for bootstrapping agentic docs in a repository with little or no agentic surface. Loaded in Phase 3 when wiring is missing.

The target layout lives in [agentic-architecture.md](agentic-architecture.md) under "Standard project wiring"; this file owns the procedure only.

A convention the repository already declares wins over every default here.

## Ground rules

- Idempotent repair: create only what is missing, never overwrite, and rerunning the scaffold on a finished repository changes nothing.
- No empty structure: create a directory, symlink, or config file only when a real asset or entry lands in it, and a prescribed `.gitignore` counts.
- No `.keep` files, no `{}` settings, and no placeholder sections.
- Repository evidence first: derive every suggestion (commands, rules, hooks, skills) from manifests, configs, and history, never from a canned list.
- Self-contained output: nothing created references the user's home, dotfiles, agent tree, user-level skills, or this skill's bundled files.
- Write budgets as numbers and name `/sync-agents --check` as the way to measure them.
- Interactive runs ask the closed questions below. Non-interactive runs apply the stated defaults, skip everything optional, and report the assumptions.
- Under `--check`, replace every creation with a precise proposal.

## Questions

Ask up to three closed questions before creating anything, batched when the tool supports it:

1. **Tools** (multi-select): pre-select the tools detectable in the repository or its history, else Claude Code and Codex.
2. **Skills** (yes or no; default no): manage project skills with the skills CLI.
3. **Assets** (multi-select; default none): rules, hooks, commands; selecting one means drafting concrete repository-derived starters.

- State in the Tools question that `AGENTS.md` is universal and not optional, and that `.agents/` materializes when content lands in it.
- A non-interactive run applies each pre-selected or default answer as given.
- Create wiring only for accepted drafts.

## Actions per selection

### Always

- Create `AGENTS.md` at the root when it is missing.
- Populate only sections with real, verified content: one-line project summary, detected commands, structure, non-obvious conventions.
- Omit a section rather than write a placeholder; in an effectively empty repository, keep the file to the few facts that hold.
- Agents execute listed commands, so check each detected command runs and document a broken one as a gotcha, not as working.
- Respect the root budget in [context-budgets.md](context-budgets.md).

### Claude Code

- No `CLAUDE.md`: Claude Code 2.1.277 and later reads `AGENTS.md` natively.
- When a parent folder holds a project `CLAUDE.md`, create a root `CLAUDE.md` with `@AGENTS.md`. The parent file stops the native load.
- For Claude-only content, follow the `CLAUDE.md` cases in "Standard project wiring" in `agentic-architecture.md`.
- The root `.gitignore` entries `**/.claude/settings.local.json` and `**/.claude/worktrees/`.
- `.claude/settings.json` only with real content, like a permission allowlist for the detected commands or a useful hook.

### Codex

- Nothing: Codex reads `AGENTS.md` natively.
- Add a `.codex/` route only after verifying the tool actually loads it at project scope.

### Skills: yes

- `.agents/skills/` plus the root `.gitignore` entry `/.agents/skills/*/`, so installed skills stay untracked.
- Track a hand-authored skill with its own `!/.agents/skills/<name>/` line after that entry.
- `.claude/skills -> ../.agents/skills` when Claude Code is selected.
- Propose skills from repository evidence, through the `find-skills` skill when available, else `npx skills search`.
- Install each accepted skill with `npx skills add <owner>/<repo> --skill <name> --yes`.
- The CLI creates and owns `skills-lock.json`; never hand-create or edit the lockfile.
- With zero accepted skills there is no lockfile until the first install.

### Assets: rules

- Draft one to three scoped rules from repository evidence: framework conventions, formatter constraints, directory contracts.
- Route each rule from one row of the `| Work | Read |` table in `AGENTS.md`, trigger first, for example `| Python files | .agents/rules/python.md |`.
- On acceptance: `.agents/rules/` with the accepted files as plain Markdown, plus their table rows, and no `.claude/rules` link.
- In a workspace, put the rules of an app in `<app>/.agents/rules/`, routed from `<app>/AGENTS.md` with app-relative paths.

### Assets: hooks

- Draft hooks from repository evidence, such as format-on-edit using the repository's configured formatter.
- On acceptance: `.agents/hooks/` with the executable scripts, and no `.claude/hooks` link.
- Register each script in `.claude/settings.json` by its path, `"$CLAUDE_PROJECT_DIR"/.agents/hooks/<script>`.

### Assets: commands

- Draft slash commands wrapping the repository's non-trivial workflows.
- On acceptance: `.claude/commands/` with the accepted files.
- Commands are tool-specific, so they live in `.claude/`, not `.agents/`.

## Conflicts

Never migrate a working layout silently:

- A fat `CLAUDE.md` with no `AGENTS.md`: propose to move shared content to `AGENTS.md`, then delete `CLAUDE.md` or keep the import and Claude-only content.
- A `CLAUDE.md` that holds only `@AGENTS.md`: propose its removal when no parent folder holds a project `CLAUDE.md`.
- A `.claude/rules -> ../.agents/rules` link: propose an `AGENTS.md` table row for each unrouted rule, then the removal of the link.
- A `.claude/hooks -> ../.agents/hooks` link: propose to register each hook by its `.agents/hooks` path, then the removal of the link.
- Leave the files of a proposal untouched until it is accepted, which overrides the Always item. A non-interactive run only reports it.
- Independent pieces, such as the root `.gitignore` entries, may still be added.
- A whole-directory `.claude -> .agents` symlink (an older convention): leave it working; flag the difference only when it causes a concrete finding.
- Existing partial wiring: fill only the gaps the selections imply.

## After scaffolding

Run the normal Phase 4 verification on everything created: link and symlink resolution, valid JSON and frontmatter, executable bits, and budgets.

Confirm with `git check-ignore` that runtime paths are ignored while tracked assets are not.
