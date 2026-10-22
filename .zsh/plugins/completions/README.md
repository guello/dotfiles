# completions plugin

Automatically creates and caches zsh completion files for CLIs with a generator command: `completion zsh`, `completion --zsh`, `completion -s zsh`, `completion`, `--completions zsh`.

To use it, add `completions` to the plugins array in your zshrc file:

```zsh
plugins=(... completions)
```

## Usage

```zsh
completions <cli> [<cli>...]              # call each cli and cache the completion files
<cli> completion zsh | completions <cli>  # cache completion text from stdin
```

Cached files are created in `${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions`, next to the completion dump, and rewritten only when the output changes. The plugin avoids `$ZSH_CACHE_DIR` because cleanup tools such as Mole empty `~/.oh-my-zsh/cache`, which breaks completion in shells that are already open. The plugin creates the directory and adds it to `fpath`.

At startup, missing completions are generated inline and activated in the current session, while an existing cache is refreshed in a detached background job only when the CLI or its link is newer than the cache.

## Settings

- `completions`: array of CLIs to load and cache.

Example usage:

```zsh
plugins=(
  # ...
  completions
)

completions=(
  docker
  gh
  kubectl
  pnpm
  tailscale
  terraform
)

. "$ZSH/oh-my-zsh.sh"
```
