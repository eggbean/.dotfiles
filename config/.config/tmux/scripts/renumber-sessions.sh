#!/bin/bash

# Changes session base index to 1 and automatically renumbers new sessions

sessions=$( tmux list-sessions -F '#S' | grep '^[0-9]\+$' | sort -n )

new=1
for old in ${sessions}; do
	tmux rename -t ${old} ${new}
	(( new++ ))
done
