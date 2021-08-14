#!/bin/bash

# Changes status-left colour when an alert triggers on a non-current session

session_id=$( tmux display-message -p -F "#{session_id}" )		 
alert=$( tmux list-sessions -F '#{session_id} #{session_alerts}' | grep -v ^$session_id | awk '/[^ ]$/ {print}' | wc -l )

(( alert > 0 )) && tmux set status-left-style "bg=#{@bell}" || tmux set status-left-style "bg=default"
