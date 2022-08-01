# ~/.bashrc: executed by bash(1) for non-login shells.

# shellcheck disable=SC1090,SC2164,SC2148,SC2155

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History file settings
HISTCONTROL=ignoreboth
HISTSIZE=2000
HISTFILESIZE=3000
HISTTIMEFORMAT="%d/%m/%y %T "
HISTIGNORE=ls:ll:la:l:cd:cdd:pwd:df:tmux:htop:git:hue:fg:date

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

# Set Starship prompt
eval "$(starship init bash)"

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

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Terminal colour mode
if [[ -f "$HOME"/.terminfo/x/xterm-24bit || -f /etc/terminfo/x/xterm-24bit ]]; then
    export TERM='xterm-24bit'
else
    export TERM='xterm-256color'
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

mosh() {
    if [[ $TMUX ]]; then
        tmux rename-window "$(echo "${@: -1}" | rev | cut -d '@' -f1 | rev | sed -E 's/\.([a-z0-9\-]+)\.compute\.amazonaws\.com$//' )"
        command mosh "$@"
        tmux set automatic-rename "on" >/dev/null
    else
        command mosh "$@"
    fi
}

# Update $PATH for the Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/google-cloud-sdk/path.bash.inc"; fi

# Enable shell command completion for gcloud cli
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# Or gcloud docker container as executable
if ! type gcloud >/dev/null 2>&1; then
    gcloud() { docker run --rm --volumes-from gcloud-config google/cloud-sdk:alpine gcloud "$@"; }
fi

# aws-cli command completion
[ -L /usr/local/bin/aws_completer ] && complete -C '/usr/local/bin/aws_completer' aws

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
if  [[ -x /usr/local/bin/_cdd ]]; then
    cdd() { while read -r x; do eval "$x" >/dev/null; done < <(dirs -l -p | /usr/local/bin/_cdd "$@"); }
    alias cd=cdd
elif
    [[ -x "$HOME"/.local/bin/_cdd ]]; then
    cdd() { while read -r x; do eval "$x" >/dev/null; done < <(dirs -l -p | "$HOME"/.local/bin/_cdd "$@"); }
    alias cd=cdd
fi

# Directory bookmarks
if [ -d "$HOME/.bookmarks" ]; then
    goto() {
        pushd -n "$PWD" >/dev/null
        local CDPATH="$HOME/.bookmarks"
        command cd -P "$@" >/dev/null
    }
    complete -W "$(command cd ~/.bookmarks && printf '%s\n' -- *)" goto
    bookmark() {
        pushd "$HOME/.bookmarks" >/dev/null
        ln -s "$OLDPWD" "$@"
        popd >/dev/null
    }
fi

# Make directory and change directory into it
mkdircd() { mkdir -p "$@" && eval pushd "\"\$$#\"" >/dev/null || return; }

# Minimalist terminal pastebin
sprunge() { curl -F 'sprunge=<-' http://sprunge.us; }

# Use a private mock hosts(5) file for completion
export HOSTFILE="$HOME/.hosts"

# broot function
[ -f ~/.config/broot/launcher/bash/br ] && . ~/.config/broot/launcher/bash/br

# fzf open multiple files
fzfr() { fzf -m -x | xargs -d'\n' -r "$@" ; }

# Return disk that directory is on
whichdisk() { realpath "$(df "${1:-.}" | command grep '^/' | cut -d' ' -f1)" ; }

# pastel colour mode
if [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]; then
    export PASTEL_COLOR_MODE='24bit'
else
    export PASTEL_COLOR_MODE='8bit'
fi

# GitHub CLI bash completion
if command -v gh >/dev/null; then
    eval "$(gh completion -s bash 2>/dev/null)"
fi

# Hashicorp bash tab completion
[ -x /usr/bin/terraform ] && complete -C /usr/bin/terraform terraform
[ -x /usr/bin/packer ] && complete -C /usr/bin/packer packer
[ -x /usr/bin/vagrant ] && . /opt/vagrant/embedded/gems/2.2.19/gems/vagrant-2.2.19/contrib/bash/completion.sh

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

# Environment variables
export LS_OPTIONS='-hv --color=always'
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_STATE_HOME="$HOME"/.local/state
export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android
export ANDROID_AVD_HOME="$XDG_DATA_HOME"/android/
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME"/android/
export ADB_VENDOR_KEY="$XDG_CONFIG_HOME"/android
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export MOSH_TITLE_NOPREFIX=
export PAGER='less -r'
export LESS='-MRQx4FX#10'
export LESSCHARSET='utf-8'
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export MANPAGER='less -+MFX +g'
export BAT_PAGER='less -+MFX -S'
export EXA_COLORS='lc=38;5;124:lm=38;5;196:uu=38;5;178:gu=38;5;178:un=38;5;141:gn=38;5;141:bO=38;5;009'
export ANSIBLE_CONFIG="$XDG_CONFIG_HOME"/ansible/ansible.cfg
export RANGER_LOAD_DEFAULT_RC=FALSE
export EDITOR='nvim'
export VISUAL='nvim'
export TMUX_PLUGIN_MANAGER_PATH="$XDG_DATA_HOME"/tmux/plugins
export GVIMINIT='let $MYGVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/gvimrc" : "$XDG_CONFIG_HOME/nvim/init.gvim" | so $MYGVIMRC'
export VIMINIT='let $MYVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/vimrc" : "$XDG_CONFIG_HOME/nvim/init.vim" | so $MYVIMRC'
if [ -n "$DISPLAY" ]; then
    export BROWSER=qutebrowser
else
    if ! type links >/dev/null 2>&1; then
        export BROWSER=links
    else
        export BROWSER=lynx
    fi
fi

# Source host specific environment
[ -f ~/.dotfiles/shell/.hostinclude/"$(hostname -s)" ] && . ~/.dotfiles/shell/.hostinclude/"$(hostname -s)"
