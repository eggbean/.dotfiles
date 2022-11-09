#!/bin/bash

pushd ~/.dotfiles >/dev/null || (echo "Cannot find ~/.dotfiles" >&2; exit 1)

# Stow binaries
if [ "$UID" -ne 0 ] && [ "$EUID" -ne 0 ]; then
  sudo bin/scripts/stow-bin.sh
else
  bin/scripts/stow-bin.sh --nosudo
fi
# Stow dotfiles
bin/scripts/stow-dotfiles.sh config

popd >/dev/null
bind -f ~/.inputrc
source ~/.bash_profile
