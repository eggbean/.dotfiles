# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=3000
HISTTIMEFORMAT="%d/%m/%y %T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/bin/dir_colors && eval "$(dircolors -b ~/bin/dir_colors)" || eval "$(dircolors -b)"
    #alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
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
		tmux rename-window "$(echo $* | rev | cut -d '@' -f1 | rev)"
		command ssh "$@"
		tmux set-window-option automatic-rename "on" 1>/dev/null
	else
		command ssh "$@"
	fi
}

mosh() {
	if [[ $TMUX ]]; then
		tmux rename-window "$(echo $* | rev | cut -d '@' -f1 | rev)"
		command mosh "$@"
		tmux set-window-option automatic-rename "on" 1>/dev/null
	else
		command mosh "$@"
	fi
}

# Update PATH for the Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/google-cloud-sdk/path.bash.inc"; fi

# Enable shell command completion for gcloud
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# Or gcloud docker container as executable
if ! type gcloud >/dev/null 2>&1; then
	gcloud() { docker run --rm --volumes-from gcloud-config google/cloud-sdk:alpine gcloud "$@"; }
fi

# Use aws-cli in an executable docker container if not installed
if ! type aws >/dev/null 2>&1; then
	aws() { docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli "$@"; }
fi

# aws command completion
complete -C '/usr/local/bin/aws_completer' aws

# Prevent accidental git stashing and alias git to hub
git() {
	if [[ "$#" -eq 1 ]] && [[ "$1" = "stash" ]]; then
		echo 'WARNING: run "git stash push" instead.'
	else
		if command -v hub >/dev/null; then command hub "$@"
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
mansearch() { 
	local q=\'
	local q_pattern="'${1//$q/$q\\$q$q}'"
	local MANPAGER="less -+MFX -p $q_pattern"
	man "$2"
}

# Download github release
dlgr() {
	URL=$(curl -s https://api.github.com/repos/"${@}"/releases/latest | \
	jq -r '.assets[].browser_download_url' | fzf)
	curl -LO ${URL}
}

# Check firewall
check-firewall() {
	gcloud compute firewall-rules describe allow-privoxy --format json | jq -r '.sourceRanges | .[]' | sort -u
	printf "\nchurch: $(dig A _church.jinkosystems.co.uk +short | tail -n1)"
	printf "\ncourtlands: $(dig A courtlands.jinkosystems.co.uk +short | tail -n1)"
	printf "\nrover: $(dig A rover.jinkosystems.co.uk +short | tail -n1)\n"
}

# Pihole may be in docker container
if ! type pihole >/dev/null 2>&1; then
	pihole() { docker exec pihole pihole "$@"; }
fi

if ! type gcloud >/dev/null 2>&1; then
	gcloud() { docker exec pihole pihole "$@"; }
fi

# Make directory and change directory into it
mkdircd() { mkdir -p "$@" && cd "$@"; }

# Minimalist terminal pastebin
sprunge() { curl -F 'sprunge=<-' http://sprunge.us; }

# Use a private mock hosts(5) file for completion
export HOSTFILE='$HOME/.hosts'

# Shared history between tmux panes
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# broot function
[ -f ~/.config/broot/launcher/bash/br ] && source ~/.config/broot/launcher/bash/br

# fzf autocomplete
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# pastel colour mode
if [ "$TERM" = 'xterm-24bit' ]; then
	export PASTEL_COLOR_MODE='24bit'
else
	export PASTEL_COLOR_MODE='8bit'
fi

# Age of files
agem() { echo $((($(date +%s) - $(date +%s -r "$1")) / 60)) minutes; }
ageh() { echo $((($(date +%s) - $(date +%s -r "$1")) / 3600)) hours; }
aged() { echo $((($(date +%s) - $(date +%s -r "$1")) / 86400)) days; }

# Colorise man pages
export LESS_TERMCAP_mb=$'\E[1;31m'		# begin bold
export LESS_TERMCAP_md=$'\E[1;36m'		# begin blink
export LESS_TERMCAP_me=$'\E[0m'			# reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;30m'	# begin reverse video
export LESS_TERMCAP_se=$'\E[0m'			# reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'		# begin underline
export LESS_TERMCAP_ue=$'\E[0m'			# reset underline
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

# Environmental variables
export LANG='en_GB.utf8'
export LANGUAGE='en_GB:en'
export LS_OPTIONS='-hv --color=always'
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_CACHE_HOME="$HOME"/.cache
export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android
export ANDROID_AVD_HOME="$XDG_DATA_HOME"/android/
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME"/android/
export ADB_VENDOR_KEY="$XDG_CONFIG_HOME"/android
export MOSH_TITLE_NOPREFIX=
export PAGER='less'
export LESS='-MRQx4FX#10'
export LESSCHARSET='utf-8'
export LESSHISTFILE="$XDG_CACHE_HOME"/.lesshst
export MANPAGER='less -+MFX +g'
export BAT_PAGER='less -+MFX -S'
export EXA_COLORS='lc=38;5;124:lm=38;5;196:uu=38;5;178:gu=38;5;178:un=38;5;141:gn=38;5;141'
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"/ansible/ansible.cfg
export EDITOR='ne'
export VISUAL='ne'

# Source host specific functions
[ -f ~/.dotfiles/$(hostname -s) ] && source ~/.dotfiles/$(hostname -s)
