# ~/.bashrc sources this file at the end if binaries have been stowed
# (therefore no further conditional statements required)

# Direnv hook
eval "$(direnv hook bash)"

# MinIO Client command completion
complete -C mclient mclient

# Directory bookmarks
if [ -d "$HOME/.bookmarks" ]; then
  goto() {
    pushd -n "$PWD" >/dev/null
    local CDPATH="$HOME/.bookmarks"
    command cd -P "$@" >/dev/null
  }
  complete -W "$(command cd ~/.bookmarks && printf '%s\n' *)" goto
  bookmark() {
    pushd "$HOME/.bookmarks" >/dev/null
    ln -s "$OLDPWD" "$@"
    popd >/dev/null
  }
fi

# CD Deluxe
cdd() { while read -r x; do eval "$x" >/dev/null; done < <(dirs -l -p | _cdd "$@"); }
alias cd='cdd'

# Combine bookmarks and cdd functions
supercd() {
  if [ "${1::1}" == '@' ]; then
    goto "$@"
  else
    cdd "$@"
  fi
}
if [[ $(type -t cdd) == function ]] && [[ $(type -t goto) == function ]]; then
  alias cd='supercd'
  complete -W "$(command cd ~/.bookmarks && printf '%s\n' -- *)" supercd
fi

# Add zoxide to shell
eval "$(zoxide init --no-cmd bash)"
z() {
  pushd -n "$PWD" >/dev/null
  __zoxide_z "$@"
}
zi() {
  pushd -n "$PWD" >/dev/null
  __zoxide_zi "$@"
}

# broot function
. ~/.config/broot/launcher/bash/br

# Hashicorp bash tab completion
complete -C /usr/bin/terraform terraform
complete -C /usr/bin/packer packer
complete -C /usr/bin/vault vault

# Set Starship prompt
eval "$(starship init bash)"
