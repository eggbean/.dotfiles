# ~/.zlogin

# neofetch and tmux sessions for welcome
if [[ -z $TMUX ]] && [[ -z $TMUX_SSH_SPLIT ]]; then
  eval "$(source /etc/os-release && typeset -p ID)"
  if [[ $ID == debian ]]; then args='--ascii_colors 7 1 1'; fi
  clear && echo && neofetch "$args"
  sessions=$(tmux list-sessions -F\#S 2>/dev/null | xargs echo)
  if [[ $sessions ]]; then
    echo "  Available tmux sessions: ""$sessions"""
  fi
  unset sessions
fi
