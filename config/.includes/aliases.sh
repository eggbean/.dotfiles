# Command defaults and aliases
alias l='ls'
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -Al'
alias sudo='sudo '  # pass aliases to superuser
alias mc='. /usr/share/mc/bin/mc-wrapper.sh'
alias wget='wget --hsts-file="$XDG_CACHE_HOME"/wget-hsts'
alias crontab='crontab -i'
alias ncdu='ncdu --exclude-kernfs --color dark'
alias xclip='xclip -r'
alias sxiv='sxiv -abs f'
alias qb='qutebrowser'
alias tv='tidy-viewer'
alias cm='cmatrix -au 2'

# Add colours when piping as I like colour
# Can always use disable switch when required
alias diff='diff --color=always --tabsize=4'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias fgrep='fgrep --color=always'
alias ack='ack --color --color-match=magenta'
alias rg='rg --color=always'
alias shellcheck='shellcheck --color=always'

# Aliases to avoid making mistakes
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv --one-file-system'

# Replace ls with exa
if command -v exa >/dev/null; then
  alias ls='exa-wrapper.sh'
else
  alias ls='/bin/ls $LS_OPTIONS'
fi

# Replace tree with tre
if command -v tre >/dev/null; then
  alias tree='tre --color always'
else
  alias tree='tree -C'
fi

# Use fzfp wrapper in tmux instead of fzf
if [[ $TMUX ]]; then alias fzf='fzfp-tmux --width=50% --height=60%'; fi

# Extras
alias fzfp='command fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias batlog='bat --paging=never -l log'
alias decomment='egrep -v "[\s]*([#;].*|^$)"'
alias nocolour="sed 's/\x1b\[[0-9;]*m//g'"
alias unicat='awk "!a[\$0]++{print}"'
alias termcolours='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/gawin/bash-colors-256/master/colors)"'
alias driveinfo='df -HTx tmpfs -x overlay -x devtmpfs'