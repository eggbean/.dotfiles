# ~/.bashrc: executed by bash(1) for interactive non-login shells.

# shellcheck disable=SC1090,SC2164,SC2148,SC2155

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Shell options
shopt -s checkwinsize
shopt -s direxpand
shopt -s globstar
shopt -s cmdhist
shopt -s lithist
shopt -s histappend
shopt -s hostcomplete
shopt -s no_empty_cmd_completion

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
. ~/.bash_aliases

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Yoloing
yolo() {
  yes | sudo "$@"
}

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

# Prevent accidental git stashing
git() {
  if [[ "$#" -eq 1 ]] && [[ "$1" == "stash" ]]; then
    echo 'WARNING: run "git stash push" instead.'
  else
    command git "$@"
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

# ENVIRONMENT VARIABLES
# xdg locations need to be set for termux
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_STATE_HOME="$HOME"/.local/state
export ADB_VENDOR_KEY="$XDG_CONFIG_HOME"/android
export ANDROID_AVD_HOME="$XDG_DATA_HOME"/android/
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME"/android/
export ANSIBLE_CONFIG="$XDG_CONFIG_HOME"/ansible/ansible.cfg
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_WEB_IDENTITY_TOKEN_FILE="$XDG_DATA_HOME"/aws/token
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME"/ripgrep/ripgreprc
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
export TMUX_PLUGIN_MANAGER_PATH="$XDG_DATA_HOME"/tmux/plugins
export VAGRANT_HOME="$XDG_DATA_HOME"/vagrant
export VAGRANT_ALIAS_FILE="$XDG_DATA_HOME"/vagrant/aliases
export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export LESSCHARSET='utf-8'
export LANGUAGE="en_GB"
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"
export LS_OPTIONS='-hv --color=always'
export MOSH_TITLE_NOPREFIX=
export PAGER='less -r'
export LESS='-MRQx4FX#10'
export MANPAGER='less -+MFX +g'
export BAT_PAGER='less -+MFX -S'
export EXA_COLORS='xa=38;5;135:lc=38;5;124:lm=38;5;196:uu=38;5;178:gu=38;5;178:un=38;5;141:gn=38;5;141:bO=38;5;009'
export RANGER_LOAD_DEFAULT_RC=FALSE
export GVIMINIT='let $MYGVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/gvimrc" : "$XDG_CONFIG_HOME/nvim/init.gvim" | so $MYGVIMRC'
export VIMINIT='let $MYVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/vimrc" : "$XDG_CONFIG_HOME/nvim/init.vim" | so $MYVIMRC'
if [ -n "$DISPLAY" ]; then
  export BROWSER=qutebrowser
else
  export BROWSER=elinks
fi
if command -v nvim >/dev/null; then
  export EDITOR='nvim'
  export VISUAL='nvim'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi

# Source host specific environment
[ -f ~/.dotfiles/config/.includes/"$(hostname -s)" ] && . ~/.dotfiles/config/.includes/"$(hostname -s)"
