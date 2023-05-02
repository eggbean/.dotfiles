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

# Functions
source ~/.dotfiles/config/.includes/functions.bash

# Environment variables
source ~/.dotfiles/config/.includes/envars.bash

# Do more stuff if binaries have been stowed
[[ -f $XDG_STATE_HOME/binaries_stowed ]] && . ~/.dotfiles/config/.includes/init.bashrc

# Source host specific environment
[[ -f ~/.dotfiles/config/.includes/$(hostname -s) ]] && . ~/.dotfiles/config/.includes/"$(hostname -s)"
