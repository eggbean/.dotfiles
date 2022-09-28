#!/bin/bash

# Changes a variable when an alert triggers on a non-current session, which can be used to style the statusline

session_id=$( tmux display-message -p -F "#{session_id}" )
alert=$( tmux list-sessions -F '#{session_id} #{session_alerts}' | grep -v ^$session_id | awk '/[^ ]$/ {print}' | wc -l )

(( alert > 0 )) && tmux set -g @session-alert on || tmux set -g @session-alert off
