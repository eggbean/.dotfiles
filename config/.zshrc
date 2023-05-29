# ~/.zshrc

# Command history
HISTSIZE=5000
SAVEHIST=5000
HISTFILE="$XDG_CACHE_HOME/zsh/zsh_history"
setopt HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY INC_APPEND_HISTORY HIST_IGNORE_SPACE

# Don't include non-alphanumeric characters in words (like bash)
autoload -U select-word-style
select-word-style bash

# Completion system
typeset -gaU fpath=($fpath /usr/local/share/bash-completion/completions)
zmodload zsh/complist
autoload -Uz compinit bashcompinit
compinit -i -d "$XDG_CACHE_HOME/zsh/zcompdump"
bashcompinit
_comp_options+=(globdots) # Complete hidden files

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
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle -e ':completion:*' hosts 'reply=($(< ~/.dotfiles/config/.includes/hosts))'

# Shift-tab to reverse completion suggestions
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Up/down arrow keys completion
for direction (up down) {
  autoload $direction-line-or-beginning-search
  zle -N $direction-line-or-beginning-search
  key=$terminfo[kcu$direction[1]1]
  for key ($key ${key/O/[})
    bindkey $key $direction-line-or-beginning-search
}

# Key bindings (including silencing some keys used in my nested tmux config)
bindkey -e
bindkey '^[[3~' delete-char
bindkey '^[[3;3~' kill-word
bindkey "^[[23;3~" ""
bindkey "^[[24;3~" ""
bindkey "^[[5;7~"  ""
bindkey "^[[6;7~"  ""

# Edit command line in visual editor
autoload -U edit-command-line && zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Enable zmv
autoload zmv

# Turn off autocomplete beeps
unsetopt LIST_BEEP
# Turn off end of history beeps
unsetopt HIST_BEEP

# Allow interective comments
setopt INTERACTIVE_COMMENTS

# Push directories to pushd dirs stack on changes
setopt AUTO_PUSHD PUSHD_SILENT PUSHD_IGNORE_DUPS

# Enable colour support of ls
eval "$(dircolors -b ~/.dotfiles/config/.includes/dir_colors)"

# Alias definitions
source ~/.dotfiles/config/.includes/aliases.sh

# Functions
source ~/.dotfiles/config/.includes/functions.sh

# Environment variables
source ~/.dotfiles/config/.includes/envars.sh

# Load antidote
if [[ -d ~/.cache/antidote ]]; then
  source ~/.cache/antidote/antidote.zsh
  antidote load ~/.dotfiles/config/.includes/zsh_plugins.txt
fi

# Do more stuff if binaries have been stowed
[[ -f $XDG_STATE_HOME/binaries_stowed ]] && . ~/.dotfiles/config/.includes/init.zshrc

# Source host specific environment
[[ -f ~/.dotfiles/config/.includes/$(hostname -s) ]] && . ~/.dotfiles/config/.includes/"$(hostname -s)"
