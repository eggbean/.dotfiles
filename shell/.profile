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
    eval "$(. /etc/os-release && typeset -p ID PRETTY_NAME)"
    [ -f /etc/machine-info ] && eval "$(. /etc/machine-info && typeset -p LOCATION)"
    linux_logo -L "$ID" -f -F "$PRETTY_NAME\nCompiled #C\n#N #M #X #T Processor#S, #R RAM\n#U\n#L\n$(hostname -f)\n$LOCATION\n#E" 2>/dev/null
    unset ID PRETTY_NAME LOCATION
  elif [ "$(uname -o)" = "Android" ]; then
    clear && macchina
  fi
  sessions=$(tmux list-sessions -F#S 2>/dev/null | xargs echo)
  if [ -n "$sessions" ]; then
    echo "  Available tmux sessions: ""$sessions"""
  fi
  unset sessions
fi

# Golang
if [ -d "/usr/local/go/bin" ]; then
  PATH=$PATH:/usr/local/go/bin
fi

# GPG Agent
eval $(gpg-agent --daemon 2>/dev/null)
export GPG_AGENT_INFO
export SSH_AUTH_SOCK
export GPG_TTY=$(tty)

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('${HOME}/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
    . "${HOME}/miniconda3/etc/profile.d/conda.sh"
  else
    PATH="${HOME}/miniconda3/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<

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
export TMUX_PLUGIN_MANAGER_PATH="$XDG_DATA_HOME"/tmux/plugins
export VAGRANT_HOME="$XDG_DATA_HOME"/vagrant
export VAGRANT_ALIAS_FILE="$XDG_DATA_HOME"/vagrant/aliases
export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export LESSCHARSET='utf-8'
export LS_OPTIONS='-hv --color=always'
export MOSH_TITLE_NOPREFIX=
export PAGER='less -r'
export LESS='-MRQx4FX#10'
export MANPAGER='less -+MFX +g'
export BAT_PAGER='less -+MFX -S'
export EXA_COLORS='lc=38;5;124:lm=38;5;196:uu=38;5;178:gu=38;5;178:un=38;5;141:gn=38;5;141:bO=38;5;009'
export RANGER_LOAD_DEFAULT_RC=FALSE
export GVIMINIT='let $MYGVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/gvimrc" : "$XDG_CONFIG_HOME/nvim/init.gvim" | so $MYGVIMRC'
export VIMINIT='let $MYVIMRC = !has("nvim") ? "$XDG_CONFIG_HOME/vim/vimrc" : "$XDG_CONFIG_HOME/nvim/init.vim" | so $MYVIMRC'
if [ ! "$(uname -o)" = "Android" ]; then
  if grep -qi microsoft /proc/version; then
    export BROWSER="/mnt/c/Program Files/qutebrowser/qutebrowser.exe"
    export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
    PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
  elif [ -n "$DISPLAY" ]; then
    export BROWSER=qutebrowser
  else
    export BROWSER=elinks
  fi
fi
if command -v nvim >/dev/null; then
  export EDITOR='nvim'
  export VISUAL='nvim'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi

# End
export PATH
