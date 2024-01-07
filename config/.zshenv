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

# Determine if mosh connection
if [[ $(who am i | grep "$(tty | cut -d"/" -f3-4)") =~ mosh ]]; then export MOSH_CONNECTION=true; fi

# Golang
if [[ -d /usr/local/go/bin ]]; then
  export PATH=$PATH:/usr/local/go/bin
fi

# pnpm
if command -v pnpm >/dev/null 2>&1; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi

# Nix package manager
if [ -e "$XDG_STATE_HOME"/nix/profile/etc/profile.d/nix.sh ]; then
  source "$XDG_STATE_HOME"/nix/profile/etc/profile.d/nix.sh
  typeset -gaU fpath=($fpath $XDG_STATE_HOME/nix/profile/share/zsh/site-functions)
fi
