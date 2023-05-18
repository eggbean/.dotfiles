# ~/.zshrc sources this file at the end if binaries have been stowed
# vim: filetype=zsh

# GitHub CLI zsh completion update
if [ $commands[gh] ]; then
  gh completion -s zsh > ~/.dotfiles/bin/zsh-completions/_gh
fi

# nginx site symlinker (lazy-loading)
nginx_ensite() {
  unfunction "$0"
  source ../../bin/bash-completions/nginx_ensite.bash
  $0 "$@"
}

nginx_dissite() {
  unfunction "$0"
  source ../../bin/bash-completions/nginx_dissite.bash
  $0 "$@"
}

# MinIO Client command completion
complete -o nospace -C mclient mclient

# broot function
[ -f ~/.config/broot/launcher/bash/br ] && source ~/.config/broot/launcher/bash/br

# Hashicorp bash tab completion
complete -o nospace -C terraform terraform
complete -o nospace -C packer packer
complete -o nospace -C vault vault

# Don't initialise these tools a second time, as it causes
# starship to show a background job when changing directories
if [[ ! $init_zshrc_sourced == true ]]; then

  # Direnv hook
  eval "$(direnv hook zsh)"

  # Add zoxide to shell
  # (workaround to retain caseless tab completion on lastest version)
  eval "$(zoxide init --no-cmd zsh)"
  z() {
    __zoxide_z "$@"
  }
  zi() {
    __zoxide_zi "$@"
  }

  # Starship prompt
  command cp ~/.config/starship.toml ~/.config/starship-zsh.toml >/dev/null
  export STARSHIP_CONFIG="$HOME/.config/starship-zsh.toml"
  starship config character.success_symbol "[%](white)"
  starship config character.error_symbol "[%](bold red)"
  eval "$(starship init zsh)"

  # Set marker to say that these have already been initialised
  init_zshrc_sourced=true

fi

### And now for some mad directory changing stuff... ###

# CD Deluxe
cdd() { while read -r x; do eval "$x" >/dev/null; done < <(dirs -l -p | _cdd "$@"); }
alias cd='cdd'

# Directory bookmarks
[[ ! -d $XDG_CACHE_HOME/bookmarks ]] && mkdir "$XDG_CACHE_HOME/bookmarks"
goto() {
  local CDPATH="$XDG_CACHE_HOME/bookmarks"
  pushd -qP "$@"
}
complete -W "$(builtin cd "$XDG_CACHE_HOME/bookmarks" && printf '%s\n' *)" goto
bookmark() {
  pushd -q "$XDG_CACHE_HOME/bookmarks"
  ln -s "$OLDPWD" "$@"
  popd -q
}

# Combine bookmarks and cdd functions to replace cd
# (this is to avoid having to remember to type goto before I even
# realise I want to, but unfortunately tab completion is lost)
supercd() {
  if [[ "${1[1]}" == "@" ]]; then
    goto "$@"
  else
    cdd "$@"
  fi
}

if [[ $(whence -w cdd) =~ function ]] && [[ $(whence -w goto) =~ function ]]; then
  alias cd='supercd'
fi
