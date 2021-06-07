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
	if command -v linux_logo >/dev/null; then
		linux_logo -f -F "$(sed '/^PRETTY_NAME="\(.*\)"$/!d; s//\1/; q;' /etc/os-release)\nCompiled #C\n#N #M #X #T Processor#S, #R RAM\n#U\n#L\n"$(hostname -f)"\n$(sed '/^LOCATION="\(.*\)"$/!d; s//\1/; q;' /etc/machine-info)\n#E"
	fi
fi

# Show available tmux sessions
if [ -z $TMUX ]; then
	sessions=$(tmux list-sessions -F#S 2> /dev/null | xargs echo)
	if [ ! -z "$sessions" ]; then
		echo "  Available tmux sessions: "$sessions""
	fi
	unset sessions
fi

# Golang
export PATH=$PATH:/usr/local/go/bin
