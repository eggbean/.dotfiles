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

# set TMPDIR if not already set
if [ -z "$TMPDIR" ]; then
	if [ -d /tmp ]; then
		export TMPDIR='/tmp'
	fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
	PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
	PATH="$HOME/.local/bin:$PATH"
fi

# Linuxlogo and tmux sessions
if [ -z "$TMUX" ]; then
	if command -v linux_logo >/dev/null; then
		eval "$(source /etc/os-release && typeset -p ID PRETTY_NAME)"
		[ -f /etc/machine-info ] && eval "$(source /etc/machine-info && typeset -p LOCATION)"
		linux_logo -L "$ID" -f -F "${PRETTY_NAME}\nCompiled #C\n#N #M #X #T Processor#S, #R RAM\n#U\n#L\n$(hostname -f)\n${LOCATION}\n#E" 2>/dev/null
		unset ID PRETTY_NAME LOCATION
	elif [ "$(uname -o)" = "Android" ]; then
		clear && macchina
	fi
	sessions=$(tmux list-sessions -F#S 2>/dev/null | xargs echo)
	if [ -n "$sessions" ]; then
		echo "	Available tmux sessions: ""$sessions"""
	fi
	unset sessions
fi

# Golang
if [ -d "/usr/local/go/bin" ]; then
	PATH=$PATH:/usr/local/go/bin
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('${HOME}/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# End
export PATH
