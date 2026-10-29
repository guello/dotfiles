_keychain_env_help() {
  emulate -L zsh
  print -r -- 'Usage: keychain-env <command>'
  print -r --
  print -r -- 'Commands:'
  print -r -- '  list            Print each item in env and its value.'
  print -r -- '  get <name>      Print the value of a Keychain item.'
  print -r -- '  set <name>      Store a value in the Keychain and export it.'
  print -r -- '  delete <name>   Delete a Keychain item and unset its variable.'
  print -r -- '  reload          Export every item in env again.'
  print -r -- '  help            Show this message.'
}

_keychain_env_error() {
  emulate -L zsh
  print -ru2 -- "keychain-env: $*"
}

_keychain_env_valid() {
  emulate -L zsh -o extended_glob
  [[ $1 == [A-Za-z_][A-Za-z0-9_]# ]] && return 0
  _keychain_env_error "invalid name: $1"
  return 1
}

_keychain_env_exists() {
  command security find-generic-password -a $USER -s $1 &>/dev/null
}

_keychain_env_confirm() {
  emulate -L zsh
  if [[ ! -t 0 ]]; then
    _keychain_env_error "confirmation needs a terminal: $2"
    return 1
  fi
  read -q "?keychain-env: $1 [y/N] "
  local rc=$?
  print -r --
  return rc
}

_keychain_env_read() {
  emulate -L zsh
  _keychain_env_valid $1 || return 1
  REPLY=$(command security find-generic-password -a $USER -s $1 -w 2>/dev/null)
  case $? in
    0) ;;
    44) _keychain_env_error "not found: $1"; return 1 ;;
    *) _keychain_env_error "failed to read: $1"; return 1 ;;
  esac
  [[ -n $REPLY ]] && return 0
  _keychain_env_error "empty value: $1"
  return 1
}

_keychain_env_export() {
  emulate -L zsh
  local REPLY
  _keychain_env_read $1 && export $1=$REPLY
}

_keychain_env_load() {
  emulate -L zsh
  local name
  integer rc=0
  for name in ${env:-}; do
    _keychain_env_export $name || rc=1
  done
  return rc
}

keychain-env() {
  emulate -L zsh
  local cmd=$1 name=$2

  if (( ! $+commands[security] )); then
    _keychain_env_error 'security command not found'
    return 1
  fi

  case $cmd in
    list|reload|help|-h|--help|'') (( $# <= 1 )) ;;
    get|set|delete) (( $# == 2 )) ;;
  esac || {
    _keychain_env_error "wrong number of arguments: $cmd"
    _keychain_env_help >&2
    return 1
  }

  case $cmd in
    list)
      local REPLY
      for name in ${env:-}; do
        if ! _keychain_env_valid $name 2>/dev/null; then
          REPLY='invalid name'
        elif ! _keychain_env_exists $name; then
          REPLY='not found'
        elif ! _keychain_env_read $name 2>/dev/null; then
          REPLY=unreadable
        fi
        print -rf '%-32s %s\n' $name $REPLY
      done
      ;;

    get)
      local REPLY
      _keychain_env_read $name && print -r -- $REPLY
      ;;

    set)
      _keychain_env_valid $name || return 1
      if _keychain_env_exists $name; then
        _keychain_env_confirm "replace the value of $name?" $name || return 1
      fi
      command security add-generic-password -U -a $USER -s $name -w || {
        _keychain_env_error "failed to store: $name"
        return 1
      }
      _keychain_env_export $name || return 1
      (( ${env[(Ie)$name]} )) || _keychain_env_error "not in env: $name"
      return 0
      ;;

    delete)
      _keychain_env_valid $name || return 1
      if ! _keychain_env_exists $name; then
        _keychain_env_error "not found: $name"
        return 1
      fi
      _keychain_env_confirm "delete $name from the Keychain?" $name || return 1
      command security delete-generic-password -a $USER -s $name &>/dev/null || {
        _keychain_env_error "failed to delete: $name"
        return 1
      }
      [[ ${(tP)name} == *export* ]] && unset $name
      (( ${env[(Ie)$name]} )) && _keychain_env_error "still in env: $name"
      return 0
      ;;

    reload)
      _keychain_env_load
      ;;

    help|-h|--help|'')
      _keychain_env_help
      ;;

    *)
      _keychain_env_error "unknown command: $cmd"
      _keychain_env_help >&2
      return 1
      ;;
  esac
}

(( $+commands[security] )) && _keychain_env_load
