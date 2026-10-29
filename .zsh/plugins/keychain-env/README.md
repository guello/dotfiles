# keychain-env plugin

Exports and manages environment variables from the macOS Keychain.

To use it, add `keychain-env` to the plugins array in your zshrc file:

```zsh
plugins=(... keychain-env)
```

## Usage

Each secret is a generic password in the login Keychain. The name is the variable name, the account is always `$USER`.

### Startup

The `env` array, which must be defined before Oh My Zsh is sourced, sets the variables that the plugin will automatically load at startup:

```zsh
# ~/.zshrc

plugins=(
  # ...
  keychain-env
)

env=(
  CONTEXT7_API_KEY
  GITHUB_API_TOKEN
  NPM_TOKEN
)

source $ZSH/oh-my-zsh.sh
```

Invalid names, items, or empty values output a warning.

### Commands

The following commands can be used to manage the Keychain items manually:

| Command                                                   | Description                                              |
| --------------------------------------------------------- | -------------------------------------------------------- |
| [`keychain-env list`](#keychain-env-list)                 | Print each item in `env` and its value                   |
| [`keychain-env get <name>`](#keychain-env-get-name)       | Print the value of a Keychain item                       |
| [`keychain-env set <name>`](#keychain-env-set-name)       | Store a value in the Keychain and export it in the shell |
| [`keychain-env delete <name>`](#keychain-env-delete-name) | Delete a Keychain item and unset its variable            |
| [`keychain-env reload`](#keychain-env-reload)             | Export every item in `env` again                         |

#### `keychain-env list`

Prints each name in `env` and the value of its Keychain item, or one of `not found`, `unreadable`, and `invalid name`.

```console
$ keychain-env list
CONTEXT7_API_KEY                 ctx7sk-****************a1b2
GITHUB_ACCESS_TOKEN              ghp_****************a1b2
NPM_TOKEN                        not found
```

#### `keychain-env get <name>`

Prints the value of one Keychain item or a warning.

```console
$ keychain-env get CONTEXT7_API_KEY
ctx7sk-****************a1b2

$ keychain-env get NPM_TOKEN
keychain-env: not found: NPM_TOKEN
```

#### `keychain-env set <name>`

Stores a value in the Keychain and exports the variable in the current shell.

```console
$ keychain-env set NPM_TOKEN
password data for new item:
retype password for new item:

$ keychain-env set CONTEXT7_API_KEY
keychain-env: replace the value of CONTEXT7_API_KEY? [y/N] y
password data for new item:
retype password for new item:
```

#### `keychain-env delete <name>`

Deletes a Keychain item and unsets its variable in the current shell.

```console
$ keychain-env delete NPM_TOKEN
keychain-env: delete NPM_TOKEN from the Keychain? [y/N] y
```

#### `keychain-env reload`

Reads every name in `env` and exports the new values in the current shell. Use it after you change `env` or change an item outside the plugin. `reload` writes the same warnings as the startup load.

```console
$ keychain-env reload
keychain-env: not found: NPM_TOKEN
```

### Completion

Commands and variables in `env` are autocompleted.

## Settings

- `env`: array of variable names to export.
