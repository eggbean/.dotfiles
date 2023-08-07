# .zshenv - Zsh environment file

# XDG directories
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"

# Use .zprofile to set environment vars for non-login, non-interactive shells
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Nix package manager
if [ -e "$XDG_STATE_HOME"/nix/profile/etc/profile.d/nix.sh ]; then
  source "$XDG_STATE_HOME"/nix/profile/etc/profile.d/nix.sh
  typeset -gaU fpath=($fpath $XDG_STATE_HOME/nix/profile/share/zsh/site-functions)
fi
