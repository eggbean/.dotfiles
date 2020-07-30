# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
	fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
	PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
	PATH="$HOME/.local/bin:$PATH"
fi

# Linuxlogo
if ! [ -n "$TMUX" ]; then
	if command -v linuxlogo >/dev/null; then
		linuxlogo -f -F "$(sed '/^PRETTY_NAME="\(.*\)"$/!d; s//\1/; q;' /etc/os-release)\nCompiled #C\n#N #M #X #T Processor#S, #R RAM\n#U\n#L\nLocation - $(sed '/^LOCATION="\(.*\)"$/!d; s//\1/; q;' /etc/machine-info)\n"$(hostname -f)"\n#E"
		motd.tcl
	fi
fi

# Show available tmux sessions
if [ -z $TMUX ]; then
	sessions=$(tmux list-sessions -F#S 2> /dev/null | xargs echo)
	if [ ! -z $sessions ]; then
		echo "  Available tmux sessions: $sessions"
	fi
	unset sessions
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

# Use cat to display web page source
cat() {
	if [[ $1 == *://* ]]; then
		curl -LsfS "$1"
	else
		command cat "$@"
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
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export MOSH_TITLE_NOPREFIX=
export PAGER='less'
export LESS='-MRQx4FX#10'
export LESSCHARSET='utf-8'
export LESSHISTFILE="$XDG_CACHE_HOME/.lesshst"
export MANPAGER='less -+MFX +g'
export BAT_PAGER='less -+MFX -S'
export EXA_COLORS="lc=38;5;124:lm=38;5;196:uu=38;5;178:gu=38;5;178:un=38;5;141:gn=38;5;141"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ansible/ansible.cfg"
export EDITOR='ne'
export VISUAL='ne'
