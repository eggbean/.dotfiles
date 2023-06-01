# ~/.bashrc sources this file at the end if binaries have been stowed
# vim: filetype=bash

# GitHub CLI bash completion
if command -v gh >/dev/null; then
  eval "$(gh completion -s bash 2>/dev/null)"
fi

# MinIO Client command completion
complete -C mclient mclient

# broot function
[ -f ~/.config/broot/launcher/bash/br ] && source ~/.config/broot/launcher/bash/br

# Hashicorp bash tab completion
complete -C terraform terraform
complete -C packer packer
complete -C vault vault

# Don't initialise these tools a second time, as it causes
# starship to show a background job when changing directories
if [[ ! $init_bashrc_sourced == true ]]; then

  # Direnv hook
  eval "$(direnv hook bash)"

  # Add zoxide to shell
  # (and add directory changes to pushd stack for CD-Deluxe)
  eval "$(zoxide init --no-cmd bash)"
  z() {
    pushd -n "$PWD" >/dev/null
    __zoxide_z "$@"
  }
  zi() {
    pushd -n "$PWD" >/dev/null
    __zoxide_zi "$@"
  }

  # Set Starship prompt
  export STARSHIP_CONFIG="$HOME"/.config/starship.toml
  eval "$(starship init bash)"

  # Set marker to say that these have already been initialised
  init_bashrc_sourced=true

fi

### And now for some mad directory changing stuff... ###

# CD Deluxe
cdd() { while read -r x; do eval "$x" >/dev/null; done < <(dirs -l -p | _cdd "$@"); }
alias cd='cdd'

# Directory bookmarks
[[ ! -d $XDG_CACHE_HOME/bookmarks ]] && mkdir "$XDG_CACHE_HOME/bookmarks"
goto() {
  pushd -n "$PWD" >/dev/null # add to dirs stack for CD-Deluxe
  local CDPATH="$XDG_CACHE_HOME/bookmarks"
  command cd -P "$@" >/dev/null
}
complete -W "$(command cd "$XDG_CACHE_HOME/bookmarks" && printf '%s\n' *)" goto
bookmark() {
  pushd "$XDG_CACHE_HOME/bookmarks" >/dev/null
  ln -s "$OLDPWD" "$@"
  popd >/dev/null
}

# Combine goto and cdd functions to replace cd
# (this is to avoid having to remember to type goto before I even
# realise I want to, but unfortunately tab completion is lost)
supercd() {
  if [[ "${1::1}" == "@" ]]; then
    goto "$@"
  else
    cdd "$@"
  fi
}
alias cd='supercd'
