# Bash Aliases

alias tree='tree -C'
alias diff='diff --color=auto --tabsize=4'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias ack='ack --color-match=magenta'
alias tmux='tmux -2u'
alias timg='timg -g50x50'
alias mc='. /usr/share/mc/bin/mc-wrapper.sh'
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
alias pihole='docker exec pihole pihole'

# Aliases to avoid making mistakes:
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'

# Command replacements
if [ -x /usr/bin/colordiff ]; then
	alias diff='colordiff'
fi

if command -v xstat >/dev/null; then
	alias stat='xstat'
fi

if command -v exa >/dev/null; then
	alias ls='exa-wrapper'
else
	alias ls='/bin/ls $LS_OPTIONS'
	alias dir='/bin/ls $LS_OPTIONS --format=vertical'
	alias vdir='/bin/ls $LS_OPTIONS --format=long'
fi

# Extras
alias decomment='egrep -v "(^#.*|^$)"'
alias termcolours='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/gawin/bash-colors-256/master/colors)"'
alias sshx="TERM=xterm-256color ssh"

alias cd..="cd .."
alias cd...="cd ../.."
alias cd....="cd ../../.."
alias cd.....="cd ../../../.."
alias cd......="cd ../../../../.."
alias cd.......="cd ../../../../../.."
