# ~/.zshrc

# Setup prompt
PROMPT='%n@%m:%1~%# '

# Command history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$XDG_CACHE_HOME/zsh/zsh_history"
setopt HIST_IGNORE_ALL_DUPS EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_SPACE EXTENDED_GLOB

# Don't include non-alphanumeric characters in words (like bash)
autoload -U select-word-style
select-word-style bash

# Completion system
typeset -gaU fpath=($fpath /usr/local/share/bash-completion/completions)
zmodload zsh/complist
autoload -Uz compinit bashcompinit
compinit -i -d "$XDG_CACHE_HOME/zsh/zcompdump"
bashcompinit

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} "ma=38;2;46;52;64;48;2;128;128;128"
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*' rehash true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle -e ':completion:*' hosts 'reply=($(< ~/.dotfiles/config/.includes/hosts))'

# Some key bindings
bindkey -e
bindkey '^U'      backward-kill-line
bindkey '^[[1~'   beginning-of-line
bindkey '^[[4~'   end-of-line
bindkey '^[[3~'   delete-char
bindkey '^[[3;3~' kill-word

# Silence some keys used in my nested tmux config
bindkey '^[[23;3~' ''
bindkey '^[[24;3~' ''
bindkey '^[[5;7~'  ''
bindkey '^[[6;7~'  ''

# Shift-tab to reverse completion suggestions
bindkey '^[[Z' reverse-menu-complete

# Up/down arrow keys partial completion
for direction (up down) {
  autoload $direction-line-or-beginning-search
  zle -N $direction-line-or-beginning-search
  key=$terminfo[kcu$direction[1]1]
  for key ($key ${key/O/[})
    bindkey $key $direction-line-or-beginning-search
}

# Edit command line in visual editor
autoload -U edit-command-line && zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Enable syntax highlighting extensions (brackets and patterns)
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets pattern)

# Highlight patterns
typeset -A ZSH_HIGHLIGHT_PATTERNS
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf \*' 'fg=white,bold,bg=red')

# Remove path/file underlining (zsh-syntax-highlighting plugin)
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

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
source ~/.dotfiles/config/.includes/aliases

# Functions
source ~/.dotfiles/config/.includes/functions

# Environment variables
source ~/.dotfiles/config/.includes/envars

# Load antidote
if [[ -d ~/.cache/antidote ]]; then
  source ~/.cache/antidote/antidote.zsh
  antidote load ~/.dotfiles/config/.includes/zsh_plugins.txt
fi

# Setup cache directories
if [[ ! -d ~/.cache/zsh ]]; then
  mkdir -p ~/.cache/zsh
  touch ~/.cache/zsh/zsh_history
fi

# Do more stuff if binaries have been stowed
[[ -f $XDG_STATE_HOME/binaries_stowed ]] && \
  . ~/.dotfiles/config/.includes/init.zshrc

# Source host specific environment
[[ -f ~/.dotfiles/config/.includes/$(hostname -s) ]] && \
  . ~/.dotfiles/config/.includes/"$(hostname -s)"
