# Environment

Applies to commands, installs, runtimes, and repository paths on this machine.

## Host

- The host is macOS on Apple Silicon with Homebrew at `$HOMEBREW_PREFIX`. The editor and terminal are VS Code and Rex.
- `$HOME` is the dotfiles repository. Its rules are in `dotfiles/repository.md`.
- Project code is in `~/Developer/@<owner>/<repo>`, scratch in `@<owner>/.tmp`, archived or obsolete repositories in `@<owner>/.archive`.
- `profile`, `plugin`, `brew`, `mas`, `lts`, `deps`, and `dotfiles` are zsh plugin functions under `~/.zsh`, not binaries.

## Runtimes and packages

- Runtimes come only from the `nodenv`, `pyenv`, and `rbenv` shims. Never add another version manager unless the project requires it.
- The default Node package manager is pnpm through Corepack. When present, the project's lockfile always defines the version.
