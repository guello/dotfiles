# Brewfile plugin

Wraps the [`brew`](https://brew.sh) CLI to automatically sync the global Brewfile in background.

To use it, add `brewfile` to the plugins array in your zshrc file:

```zsh
plugins=(... brewfile)
```

## Usage

| Command       | Description                                                                      |
| ------------- | -------------------------------------------------------------------------------- |
| `brew dump`   | Dump the installed brews, casks, taps, and App Store apps to the global Brewfile |
| `brew fresh`  | Update, upgrade, clean up, dump, and run doctor                                  |
| `brew global` | Run `brew bundle` against the global Brewfile                                    |
| `brew check`  | Verify that everything is correctly installed                                    |
| `brew reset`  | Alias of `brew update-reset`                                                     |

`brew fresh` reads the `HOMEBREW_*` settings in the current environment, such as `HOMEBREW_UPGRADE_GREEDY` or `HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS`, and forwards the specified option to `brew upgrade`. By default, it doesn't upgrade App Store apps, which need `mas upgrade`.

Any other `brew` subcommand is passed unchanged. After a successful writing command (`install`, `uninstall`, `upgrade`, `tap`, etc.) the Brewfile is dumped in a detached background job and the prompt returns immediately.

## Settings

- `HOMEBREW_BUNDLE_FILE_GLOBAL`: path to a custom global Brewfile. If not set, Homebrew checks `${XDG_CONFIG_HOME}/homebrew/Brewfile`, `~/.homebrew/Brewfile`, and `~/.Brewfile`.
