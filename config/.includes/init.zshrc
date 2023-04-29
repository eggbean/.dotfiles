# ~/.zshrc sources this file at the end if binaries have been stowed
# (therefore no further conditional statements required)

# # MinIO Client command completion
# complete -C mclient mclient

# # broot function
# . ~/.config/broot/launcher/bash/br

# Hashicorp bash tab completion
complete -o nospace -C /usr/bin/terraform terraform
complete -o nospace -C /usr/bin/packer packer
complete -o nospace -C /usr/bin/vault vault

# ### And now for some mad directory changing stuff... ###

# # Directory bookmarks
# if [ -d "$HOME/.bookmarks" ]; then
#   goto() {
#     pushd -n "$PWD" >/dev/null
#     local CDPATH="$HOME/.bookmarks"
#     command cd -P "$@" >/dev/null
#   }
#   complete -W "$(command cd ~/.bookmarks && printf '%s\n' *)" goto
#   bookmark() {
#     pushd "$HOME/.bookmarks" >/dev/null
#     ln -s "$OLDPWD" "$@"
#     popd >/dev/null
#   }
# fi

# # CD Deluxe (I love this tool - far more people should use it!)
# cdd() { while read -r x; do eval "$x" >/dev/null; done < <(dirs -l -p | _cdd "$@"); }
# alias cd='cdd'

# # Combine bookmarks and cdd functions
# # (this is to avoid having to remember to type goto before I even
# # realise I want to, but unfortunately tab completion is lost)
# supercd() {
#   if [ "${1::1}" == '@' ]; then
#     goto "$@"
#   else
#     cdd "$@"
#   fi
# }
# if [[ $(type -t cdd) == function ]] && [[ $(type -t goto) == function ]]; then
#   alias cd='supercd'
#   complete -W "$(command cd ~/.bookmarks && printf '%s\n' -- *)" supercd
# fi

# Don't initialise these tools a second time, as it causes
# starship to show a background job when changing directories
if [[ ! "$init_bashrc_sourced" == true ]]; then

  # Direnv hook
  eval "$(direnv hook bash)"

  # Add zoxide to shell
  # (and add directory changes to pushd stack for CD-Deluxe)
  eval "$(zoxide init bash)"

  # Starship prompt
  rm ~/.config/starship-zsh.toml
  cp ~/.config/starship.toml ~/.config/starship-zsh.toml
  export STARSHIP_CONFIG="$HOME/.config/starship-zsh.toml"
  starship config character.success_symbol "[%](white)"
  starship config character.error_symbol "[%](bold red)"
  eval "$(starship init zsh)"

  # Set marker to say that these have already been initialised
  init_bashrc_sourced=true

fi
