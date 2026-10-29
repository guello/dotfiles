_node_modules_bin_update() {
  emulate -L zsh

  if [[ -n ${_node_modules_bin_current:-} ]]; then
    local index=${path[(Ie)$_node_modules_bin_current]}
    (( index )) && path[$index]=()
    unset _node_modules_bin_current
  fi

  local dir=$PWD bin
  while [[ -n $dir ]]; do
    if [[ -d $dir/node_modules/.bin ]]; then
      bin=$dir/node_modules/.bin
      if (( ! ${path[(Ie)$bin]} )); then
        path+=($bin)
        typeset -g _node_modules_bin_current=$bin
      fi
      return 0
    fi
    [[ $dir == / ]] && break
    dir=${dir:h}
  done
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _node_modules_bin_update
_node_modules_bin_update
