# Bash Aliases
alias sudo='sudo '
alias tree='tree -C'
alias diff='diff --color=always --tabsize=4'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias fgrep='fgrep --color=always'
alias ack='ack --color-match=magenta'
alias tmux='tmux -2u'
alias mc='. /usr/share/mc/bin/mc-wrapper.sh'
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
alias shellcheck='shellcheck --color=always'

# Aliases to avoid making mistakes:
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'

# Command replacements
if command -v xstat >/dev/null; then
	alias stat='xstat'
fi

if command -v exa >/dev/null; then
	alias ls='exa-wrapper.sh'
else
	alias ls='/bin/ls $LS_OPTIONS'
fi

if command -v whoisrb >/dev/null; then
	alias whois='whoisrb'
fi

# Extras
alias decomment='egrep -v "(^#.*|^$)"'
alias termcolours='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/gawin/bash-colors-256/master/colors)"'
alias sshx="TERM=xterm-256color ssh"
alias timg='timg -g50x50'
alias pihole='docker exec pihole pihole'

# Changing directory quickly
alias ..="builtin cd .."
alias ...="builtin cd ../.."
alias ....="builtin cd ../../.."
alias .....="builtin cd ../../../.."
alias ......="builtin cd ../../../../.."
alias .......="builtin cd ../../../../../.."

# Directory shortcuts
alias projects="pushd ~/Documents/projects"
alias docker-stuff="pushd /srv/docker"
