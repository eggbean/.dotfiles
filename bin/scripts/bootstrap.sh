#!/bin/bash

cd ~/.dotfiles || (echo "Cannot find ~/.dotfiles" >&2; exit 1)

# Stow binaries
if [ "$UID" -ne 0 ] && [ "$EUID" -ne 0 ]; then
  sudo bin/scripts/stow-bin.sh
else
  bin/scripts/stow-bin.sh --nosudo
fi
# Stow dotfiles
bin/scripts/stow-dotfiles.sh config

source ~/.bash_profile
