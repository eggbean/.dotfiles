# ~/.bashrc: executed by bash(1) for interactive non-login shells.

# shellcheck disable=SC1090,SC2164,SC2148,SC2155

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Shell options
shopt -s direxpand
shopt -s globstar
shopt -s lithist
shopt -s histappend
shopt -s hostcomplete
shopt -s no_empty_cmd_completion

# History file settings
HISTCONTROL=ignoreboth
HISTTIMEFORMAT="%d/%m/%y %T "
HISTIGNORE=ls:ll:la:l:pwd:df:du:history:tmux:htop:fg:man:mans:date:hue
HISTSIZE=5000
HISTFILESIZE=5000

# Shared history between tmux panes
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable color support of ls
eval "$(dircolors -b ~/.dotfiles/bin/scripts/dir_colors)"

# Alias definitions
. ~/.aliases

# Use a private mock hosts(5) file for completion
export HOSTFILE="$HOME/.hosts"

# GitHub CLI bash completion
if command -v gh >/dev/null; then
  eval "$(gh completion -s bash 2>/dev/null)"
fi

# Functions
source ~/.dotfiles/config/.includes/functions.bash

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
export LC_ALL="en_GB.UTF-8" 2>/dev/null
export LS_OPTIONS='-hv --color=always'
export CLICOLOR=1
export CLICOLOR_FORCE=1
export MOSH_TITLE_NOPREFIX=
export PAGER='less -r'
export LESS='-MRQx4FX#10'
export MANPAGER='less -+MFX +g'
export BAT_PAGER='less -+MFX -S'
export EXA_COLORS='xa=38;5;135:lc=38;5;124:lm=38;5;196:uu=38;5;178:gu=38;5;178:un=38;5;141:gn=38;5;141:bO=38;5;009'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export RANGER_LOAD_DEFAULT_RC=FALSE
export STARSHIP_CONFIG="$HOME"/.config/starship.toml
export GVIMINIT='let $MYGVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/gvimrc" : "$XDG_CONFIG_HOME/nvim/init.gvim" | so $MYGVIMRC'
export VIMINIT='let $MYVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/vimrc" : "$XDG_CONFIG_HOME/nvim/init.vim" | so $MYVIMRC'

# Set COLORTERM if Windows Terminal
[[ $WT_SESSION ]] && export COLORTERM='truecolor'

# Browser
if [[ $DISPLAY ]]; then
  export BROWSER=qutebrowser
else
  export BROWSER=elinks
fi

# Text Editor
if command -v nvim >/dev/null; then
  export EDITOR='nvim'
  export VISUAL='nvim'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi

# Do more stuff if binaries have been stowed
[[ -f $XDG_STATE_HOME/binaries_stowed ]] && . ~/.dotfiles/config/.includes/init.bashrc

# Source host specific environment
[[ -f ~/.dotfiles/config/.includes/$(hostname -s) ]] && . ~/.dotfiles/config/.includes/"$(hostname -s)"
