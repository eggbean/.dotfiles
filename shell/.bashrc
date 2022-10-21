# ~/.bashrc: executed by bash(1) for interactive non-login shells.

# shellcheck disable=SC1090,SC2164,SC2148,SC2155

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# History file settings
HISTCONTROL=ignoreboth
HISTTIMEFORMAT="%d/%m/%y %T "
HISTIGNORE=ls:ll:la:l:pwd:df:du:history:tmux:htop:fg:man:mans:date:hue
if [ ! "$(uname -o)" = "Android" ] && [ "$(arch)" = "x86_64" ]; then
  HISTSIZE=2000
  HISTFILESIZE=10000
else
  HISTSIZE=1000
  HISTFILESIZE=5000
fi

# Shared history between tmux panes
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Shell options
shopt -s checkwinsize
shopt -s direxpand
shopt -s globstar
shopt -s histappend
shopt -s hostcomplete
shopt -s no_empty_cmd_completion

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set COLORTERM if Windows Terminal
[ -n "$WT_SESSION" ] && export COLORTERM='truecolor'

# Set Starship prompt
eval "$(starship init bash)"

# Direnv hook
eval "$(direnv hook bash)"

# Enable color support of ls
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dotfiles/bin/scripts/dir_colors && eval "$(dircolors -b ~/.dotfiles/bin/scripts/dir_colors)" || eval "$(dircolors -b)"
fi

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Rename tmux windows automatically to hostname
ssh() {
  if [[ $TMUX ]]; then
    tmux rename-window "$(echo "${@: -1}" | rev | cut -d '@' -f1 | rev | sed -E 's/\.([a-z0-9\-]+)\.compute\.amazonaws\.com$//' )"
    command ssh "$@"
    tmux set automatic-rename "on" >/dev/null
  else
    command ssh "$@"
  fi
}

# mosh() {
#   if [[ $TMUX ]]; then
#     tmux rename-window "$(echo "${@: -1}" | rev | cut -d '@' -f1 | rev | sed -E 's/\.([a-z0-9\-]+)\.compute\.amazonaws\.com$//' )"
#     command mosh "$@"
#     tmux set automatic-rename "on" >/dev/null
#   else
#     command mosh "$@"
#   fi
# }

# https://superuser.com/a/1315015/8972
mosh() {
  case $@ in
    hostname)
      command mosh osiris.jinkosystems.co.uk -- bash -c 'echo "Bouncing via bastion..." && echo && ssh hostname.domain.com'
      ;;
    *)
      command mosh "$@"
      ;;
  esac
}

# Update $PATH for the Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/google-cloud-sdk/path.bash.inc"; fi

# Enable shell command completion for gcloud cli
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# Or gcloud docker container as executable
if ! type gcloud >/dev/null 2>&1; then
  gcloud() { docker run --rm --volumes-from gcloud-config google/cloud-sdk:alpine gcloud "$@"; }
fi

# MinIO Client command completion
complete -C mclient mclient

# Rename tmux windows when attaching to docker containers
docker() {
  if [[ $TMUX ]] && [[ "$1" == "attach" ]]; then
    tmux rename-window "$2"
    command docker "$@"
    tmux set automatic-rename "on" >/dev/null
  else
    command docker "$@"
  fi
}

# Prevent accidental git stashing, replace git browse and alias git to hub
git() {
  if [[ "$#" -eq 1 ]] && [[ "$1" == "stash" ]]; then
    echo 'WARNING: run "git stash push" instead.'
  elif [[ "$1" == "browse" ]]; then
    # Fix $BROWSER needing escaping backslash for gh
    if grep -qi microsoft /proc/version; then
      local BROWSER="/mnt/c/Program\ Files/qutebrowser/qutebrowser.exe"
    fi
    gh browse "${@:2}"
  else
    if command -v hub >/dev/null; then
      command hub "$@"
    else
      command git "$@"
    fi
  fi
}

# Use cat to display web page source and change tabs to 4 spaces
cat() {
  if [[ $1 == *://* ]]; then
    curl -LsfS "$1"
  else
    command cat "$@" | expand -t4
  fi
}

# Search man page for string
mans() {
  local q="\'"
  local q_pattern="'${1//$q/$q\\$q$q}'"
  local MANPAGER="less -+MFX -p $q_pattern"
  man "$2"
}

# CD Deluxe
if command -v _cdd >/dev/null; then
  cdd() { while read -r x; do eval "$x" >/dev/null; done < <(dirs -l -p | _cdd "$@"); }
  alias cd='cdd'
fi

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

# Combine bookmarks and cdd functions
supercd() {
  if [ "${1::1}" == '@' ]; then
    # local CDPATH="$HOME/.bookmarks"
    goto "$@"
  else
    cdd "$@"
  fi
}

if [[ $(type -t cdd) == function ]] && [[ $(type -t goto) == function ]]; then
  alias cd='supercd'
  complete -W "$(command cd ~/.bookmarks && printf '%s\n' -- *)" supercd
fi

# Make directory and change directory into it
mkdircd() { mkdir -p "$@" && eval pushd "\"\$$#\"" >/dev/null || return; }

# Minimalist terminal pastebin to pipe to
sprunge() { curl -F 'sprunge=<-' http://sprunge.us; }

# Use a private mock hosts(5) file for completion
export HOSTFILE="$HOME/.hosts"

# broot function
[ -f ~/.config/broot/launcher/bash/br ] && . ~/.config/broot/launcher/bash/br

# Return disk that directory is on
whichdisk() { realpath "$(df "${1:-.}" | command grep '^/' | cut -d' ' -f1)" ; }

# GitHub CLI bash completion
if command -v gh >/dev/null; then
  eval "$(gh completion -s bash 2>/dev/null)"
fi

# Hashicorp bash tab completion
[ -x /usr/bin/terraform ] && complete -C /usr/bin/terraform terraform
[ -x /usr/bin/packer ] && complete -C /usr/bin/packer packer
[ -x /usr/bin/vault ] && complete -C /usr/bin/vault vault

# Age of files
agem() { echo $((($(date +%s) - $(date +%s -r "$1")) / 60)) minutes; }
ageh() { echo $((($(date +%s) - $(date +%s -r "$1")) / 3600)) hours; }
aged() { echo $((($(date +%s) - $(date +%s -r "$1")) / 86400)) days; }

# Colourise man pages
export LESS_TERMCAP_mb=$'\E[1;31m'      # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'      # begin blink
export LESS_TERMCAP_me=$'\E[0m'         # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;30m'  # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'         # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'      # begin underline
export LESS_TERMCAP_ue=$'\E[0m'         # reset underline
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

# fzf
if command -v fzf >/dev/null; then
  source ~/.dotfiles/bin/completions/fzf-completions.bash
  source ~/.dotfiles/bin/completions/fzf-keybindings.bash

  export FZF_DEFAULT_OPTS=" \
    --ansi \
    --reverse \
    --bind=ctrl-a:toggle-all \
    --bind=ctrl-alt-j:preview-down \
    --bind=ctrl-alt-k:preview-up \
    --bind=ctrl-d:preview-page-down \
    --bind=ctrl-u:preview-page-up \
    --bind=alt-bs:clear-query \
    --bind=ctrl-h:deselect \
    --bind=ctrl-l:select \
    --color fg:#F8F8F2 \
    --color fg+:#F8F8F2 \
    --color bg:-1 \
    --color bg+:-1 \
    --color hl:#50FA7B \
    --color hl+:#FFB86C \
    --color info:#BD93F9 \
    --color prompt:#50FA7B \
    --color pointer:#FF79C6 \
    --color marker:#FF5555 \
    --color spinner:#8BE9FD \
    --color header:#8BE9FD \
  "
  # fzf open multiple files
  fzfr() { fzf -m -x | xargs -d'\n' -r "$@" ; }
fi

# Source host specific environment
[ -f ~/.dotfiles/shell/.includes/"$(hostname -s)" ] && . ~/.dotfiles/shell/.includes/"$(hostname -s)"
