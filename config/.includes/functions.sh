# Shell functions (for bash and zsh)

[[ $BASH_VERSION ]] && shell=bash
[[ $ZSH_VERSION ]] && shell=zsh

# Rename tmux windows automatically to hostname
ssh() {
  if [[ $TMUX ]]; then
    tmux rename-window "$(echo "${@: -1}" | \
      rev | cut -d '@' -f1 | rev | sed -E 's/\.([a-z0-9\-]+)\.compute\.amazonaws\.com$//' )"
    command ssh "$@"
    tmux set automatic-rename "on" >/dev/null
  else
    command ssh "$@"
  fi
}

# mosh to bastion (mobile connection) and ssh from there (stable connection)
# This way ports for mosh only need to be opened on the bastion
# There's no need for a mosh connection from the bastion
# Guardian Agent (sga-ssh) is used to forward ssh-agent from local host
mosh() {
  [[ $TMUX ]] && tmux rename-window "$@"
  case $@ in
    bastet) command mosh bastet.jinkosystems.co.uk ;;
         *) command mosh bastet.jinkosystems.co.uk -- \
              bash -c "printf '%s\n\n' 'Bouncing via bastion...' && \
              sga-ssh $@" ;;
  esac
  [[ $TMUX ]] && tmux set automatic-rename "on" >/dev/null
}

# Rename tmux windows when attaching to docker containers
docker() {
  if [[ $TMUX ]] && [[ $1 == attach ]]; then
    tmux rename-window "$2"
    command docker "$@"
    tmux set automatic-rename "on" >/dev/null
  else
    command docker "$@"
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

# ix.io command line pastebin
ix() {
  local opts
  local OPTIND
  [ -f "$HOME/.netrc" ] && opts='-n'
  while getopts ":hd:i:n:" x; do
    case $x in
      h) echo "ix [-d ID] [-i ID] [-n N] [opts]"; return;;
      d) $echo curl $opts -X DELETE ix.io/$OPTARG; return;;
      i) opts="$opts -X PUT"; local id="$OPTARG";;
      n) opts="$opts -F read:1=$OPTARG";;
    esac
  done
  shift $(($OPTIND - 1))
  [ -t 0 ] && {
    local filename="$1"
    shift
    [ "$filename" ] && {
      curl $opts -F f:1=@"$filename" $* ix.io/$id
      return
    }
    echo "^C to cancel, ^D to send."
  }
  curl $opts -F f:1='<-' $* ix.io/$id
}

# Yoloing
yolo() { yes | sudo "$@"; }

# tre $EDITOR aliasing
tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }

# Make directory and change directory into it
take() { mkdir -p "$@" && eval pushd "\"\$$#\"" >/dev/null || return; }

# Return disk that directory is on
whichdisk() { realpath "$(df "${1:-.}" | command grep '^/' | cut -d' ' -f1)" ; }

# Age of files
agem() { echo $((($(date +%s) - $(date +%s -r "$1")) / 60)) minutes; }
ageh() { echo $((($(date +%s) - $(date +%s -r "$1")) / 3600)) hours; }
aged() { echo $((($(date +%s) - $(date +%s -r "$1")) / 86400)) days; }

# fzf
if command -v fzf >/dev/null; then
  source ~/.dotfiles/bin/"$shell"-completions/fzf-completions."$shell"
  source ~/.dotfiles/bin/"$shell"-completions/fzf-keybindings."$shell"

  export FZF_DEFAULT_OPTS=" \
    --ansi \
    --reverse \
    --bind=ctrl-a:toggle-all \
    --bind=pgdn:preview-page-down \
    --bind=pgup:preview-page-up \
    --bind=alt-j:preview-half-page-down \
    --bind=alt-k:preview-half-page-up \
    --bind=ctrl-d:preview-page-down \
    --bind=ctrl-u:preview-page-up \
    --bind=alt-bs:clear-query \
    --bind=ctrl-h:deselect \
    --bind=ctrl-l:select \
    --color fg:#F8F8F2 \
    --color fg+:#F8F8F2 \
    --color bg:-1 \
    --color bg+:-1 \
    --color hl:#50FA7B \
    --color hl+:#FFB86C \
    --color info:#BD93F9 \
    --color prompt:#50FA7B \
    --color pointer:#FF79C6 \
    --color marker:#FF5555 \
    --color spinner:#8BE9FD \
    --color header:#8BE9FD \
  "
  # fzf open multiple files
  fzfr() { fzf -m -x | xargs -d'\n' -r "$@" ; }
fi

# Colourise man pages
man() {
  env \
    LESS_TERMCAP_mb=$'\e[1;31m' \
    LESS_TERMCAP_md=$'\e[1;36m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;30m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[1;32m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_mr=$(tput rev) \
    LESS_TERMCAP_mh=$(tput dim) \
    LESS_TERMCAP_ZN=$(tput ssubm) \
    LESS_TERMCAP_ZV=$(tput rsubm) \
    LESS_TERMCAP_ZO=$(tput ssupm) \
    LESS_TERMCAP_ZW=$(tput rsupm) \
    GROFF_NO_SGR=1 \
    man "$@"
}

# Search man page for string
if [[ $shell == bash ]]; then
  mans() {
    local q="\'"
    local q_pattern="'${1//$q/$q\\$q$q}'"
    local MANPAGER="less -+MFX -p $q_pattern"
    man "$2"
  }
elif [[ $shell == zsh ]]; then
  mans() {
    MANPAGER="less -+MFX -p ${(qq)1}" man $2
  }
fi
