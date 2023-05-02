# ~/.zshrc

# Command history
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt histignorealldups extendedhistory incappendhistory

# Don't include non-alphanumeric characters in words, like bash
autoload -U select-word-style
select-word-style bash

# Completion system
typeset -gaU fpath=($fpath /usr/local/share/bash-completion/completions)
autoload -Uz compinit bashcompinit
compinit -i
bashcompinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*' rehash true
zstyle -e ':completion:*' hosts 'reply=($(< ~/.hosts))'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Key bindings
bindkey -e
bindkey '^[[3~' delete-char
bindkey '^[[3;3~' kill-word
bindkey "^[[23;3~" ""
bindkey "^[[24;3~" ""
bindkey "^[[5;7~"  ""
bindkey "^[[6;7~"  ""

for direction (up down) {
  autoload $direction-line-or-beginning-search
  zle -N $direction-line-or-beginning-search
  key=$terminfo[kcu$direction[1]1]
  for key ($key ${key/O/[})
    bindkey $key $direction-line-or-beginning-search
}

# Turn off autocomplete beeps
unsetopt LIST_BEEP
# Turn off end of history beeps
unsetopt HIST_BEEP

# Enable color support of ls
eval "$(dircolors -b ~/.dotfiles/bin/scripts/dir_colors)"

# Alias definitions
source $HOME/.aliases

# Functions
source ~/.dotfiles/config/.includes/functions.zsh

# Environment variables
source ~/.dotfiles/config/.includes/envars.zsh

# Do more stuff if binaries have been stowed
[[ -f $XDG_STATE_HOME/binaries_stowed ]] && . ~/.dotfiles/config/.includes/init.zshrc

# Source host specific environment
[[ -f ~/.dotfiles/config/.includes/$(hostname -s) ]] && . ~/.dotfiles/config/.includes/"$(hostname -s)"
