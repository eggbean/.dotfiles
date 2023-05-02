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
compinit
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

source ~/.dotfiles/config/.includes/completions.zsh

# Key bindings
bindkey -e
# bindkey '^[[3~' delete-char
bindkey '^[[3;3~' kill-word

# Silence keys used in my nested tmux configuration
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

# fzf
if command -v fzf >/dev/null; then
  source ~/.dotfiles/bin/zsh-completions/fzf-completions.zsh
  source ~/.dotfiles/bin/zsh-completions/fzf-keybindings.zsh

  export FZF_DEFAULT_OPTS=" \
    --ansi \
    --reverse \
    --bind=ctrl-a:toggle-all \
    --bind=pgdn:preview-page-down \
    --bind=pgup:preview-page-up \
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

# Colourise man pages
man() {
  env \
    LESS_TERMCAP_mb=$'\e[1;31m' \
    LESS_TERMCAP_md=$'\e[1;36m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;30m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[1;32m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_mr=$(tput rev) \
    LESS_TERMCAP_mh=$(tput dim) \
    LESS_TERMCAP_ZN=$(tput ssubm) \
    LESS_TERMCAP_ZV=$(tput rsubm) \
    LESS_TERMCAP_ZO=$(tput ssupm) \
    LESS_TERMCAP_ZW=$(tput rsupm) \
    man "$@"
}

# Search man page for string
mans(){
  local -x MANPAGER="less -+MFX -p ${(q+)1}"
  man "$2"
}

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
export TIMEFMT=$'real\t%E\nuser\t%U\nsys\t%S'
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
if (( $+commands[nvim] )); then
  export EDITOR='nvim'
  export VISUAL='nvim'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi

# Do more stuff if binaries have been stowed
[[ -f $XDG_STATE_HOME/binaries_stowed ]] && . ~/.dotfiles/config/.includes/init.zshrc

# Source host specific environment
[[ -f ~/.dotfiles/config/.includes/$(hostname -s) ]] && . ~/.dotfiles/config/.includes/"$(hostname -s)"
