# Command defaults and aliases
alias l='ls'
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -Al'
alias sudo='sudo '
alias tree='tree -C'
alias diff='diff --color=always --tabsize=4'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias fgrep='fgrep --color=always'
alias ack='ack --color-match=magenta'
alias mc='. /usr/share/mc/bin/mc-wrapper.sh'
alias wget='wget --hsts-file="$XDG_CACHE_HOME"/wget-hsts'
alias shellcheck='shellcheck --color=always'
alias crontab='crontab -i'
alias ncdu='ncdu --exclude-kernfs --color dark'
alias xclip='xclip -r'

# Aliases to avoid making mistakes:
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'

# Use nvim appimage if available
if command -v nvim >/dev/null; then
	alias vi='nvim'
fi

# Use nvim for vimdiff
if command -v nvim >/dev/null; then
	alias vimdiff='nvim -d'
fi

# Command replacements
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
alias nocolour="sed 's/\x1b\[[0-9;]*m//g'"
alias fzfp='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias batlog='bat --paging=never -l log'
alias driveinfo='df -HTx tmpfs -x overlay -x devtmpfs'
alias cm='cmatrix -au 2'

# Changing directory quickly
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
