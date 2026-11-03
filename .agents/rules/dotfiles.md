# Dotfiles repository

These rules apply only when `$HOME` is the active repository. Treat every file under `~` as potentially tracked and preserve unrelated work.

## Portability

- Every tracked file must work on a fresh machine: use `$HOME`, `~`, `$HOMEBREW_PREFIX`, `$XDG_*`, or a repository-relative path.
- Never write a user path, hostname, serial, personal email, or other machine identity into a tracked file; identity stays in its ignored owners.
- The `/opt/homebrew` and `/usr/local` PATH pair is the only approved machine-location exception, because bootstrap runs before `$HOMEBREW_PREFIX` exists.
- Standard system paths such as `/bin/sh`, `/etc`, `/Users/Shared`, and `/usr/bin/env` are portable; any other exception requires explicit approval.
- The writing hook and `pre-push` reject committed user paths; the managed-file hook blocks edits through linked or generated routes.
- Outside `$HOME`, the writing hook also rejects `~`-anchored references to the agent tree or `~/Developer`, so a project file never depends on these dotfiles.

## Tracking

- `.gitignore` is an allowlist that starts with `/*`; add a matching `!` rule with every new tracked path.
- Track a machine file with fixed content in place, never generated or linked: `.hushlogin` and `.CFUserTextEncoding`.
- Plain-text files under `~/Library` follow the same rule: `KeyBindings/DefaultKeyBinding.dict` and the launch agents.
- Keep VS Code user configuration in `.vscode/user`; `Library/Application Support/Code/User` is a relative symlink to it.

## Commit convention

- `.commitlintrc.json` and the `commit-msg` hook enforce an allowlisted lower-case type and optional scope, and a subject with no trailing period.
- Leave a blank line before any body and keep the subject lower-case.
- Allowed types and scopes are in `.commitlintrc.json` under `type-enum` and `scope-enum`: never use the `feat`, `fix`, or `refactor` types or scopes outside the allowlist.
- Use `agents` for shared agent configuration and a tool scope only for that tool's native, non-shared configuration.
- When the commit sections change, update `git-commit-instructions` in `.codex/settings.toml` and the Copilot commit prompt in `.vscode/settings.json`.
- Keep the type list in `.github/ISSUE_TEMPLATE/agent_task.yml` equal to `type-enum`.

## Commit types

Choose the type from the changed path, and add the scope of the tool when one fits.

- `zsh(plugin|theme)` covers Zsh startup, aliases, plugins, and prompt themes.
- `shell` covers shell files that are not specific to Zsh, such as `.profile`, Bash files, and the shellcheck config.
- A commit that changes only a Zsh integration, such as the `defaults` plugin, uses `zsh(plugin)`.
- `macos(defaults|launchd)` covers system preference files and all `.config/launchd` plists.
- `git(gh|glab)` covers Git config and hooks, Git host CLIs, and Git TUIs.
- `gui(ghostty)` covers desktop apps that have no type of their own, and `editor` covers editors and `.editorconfig`.
- `node(npm)`, `ruby`, and `python` each cover one runtime with its version manager, packages, and linters.
- `chore` covers repository-wide files, such as `.gitignore`, commitlint, the formatter, the README, and issue templates.
