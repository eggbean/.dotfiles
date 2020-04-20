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
	uname -s -n -r -v -m;
	linuxlogo -f -L debian -F "Debian GNU/Linux 6.0 Squeeze\nKernel Version #V\nCompiled #C\n#N #M #X #T Processor#S, #R RAM\n#B Bogomips Total\n#U\n#L\n#H.jinkosystems.co.uk\n#E";
	motd.tcl;
fi

# Rename tmux windows automatically to hostname
ssh() {
	if [[ $TMUX ]]; then
		tmux rename-window "$(echo $* | rev | cut -d ' ' -f1 | rev | cut -d . -f 1)"
		command ssh "$@"
		tmux set-window-option automatic-rename "on" 1>/dev/null
	else
		command ssh "$@"
	fi
}

# Prevent accidental git stashing
git() {
	if [[ "$#" -eq 1 ]] && [[ "$1" = "stash" ]];then
		echo 'WARNING: run "git stash push" instead.'
	else
		command git "$@"
	fi
}

# Make directory and change directory into it
mkdircd () { mkdir "$@" && cd "$@"; }

# Minimalist terminal pastebin
sprunge() {
curl -F 'sprunge=<-' http://sprunge.us
}

# Use a private mock hosts(5) file for completion
export HOSTFILE='$HOME/.hosts'

# Colorise man pages
export LESS_TERMCAP_mb=$'\E[1;31m'	   # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'	   # begin blink
export LESS_TERMCAP_me=$'\E[0m'		   # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'		   # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'	   # begin underline
export LESS_TERMCAP_ue=$'\E[0m'		   # reset underline

# More environmental variables
export EDITOR='ne'
export VISUAL='vim'
export LESSCHARSET='utf-8'
