#!/bin/bash

pushd ~/.dotfiles >/dev/null || exit 1

eval "$(. /etc/os-release && typeset -p ID)"
if [ "$ID" == "ol" ]; then
  sudo dnf config-manager --set-enabled ol9_developer_EPEL
  sudo dnf upgrade -y
  sudo dnf install -y git htop neofetch shellcheck stow tree
fi

# Stow binaries
if [ "$UID" -ne 0 ] && [ "$EUID" -ne 0 ]; then
  sudo bin/scripts/stow-bin.sh
else
  bin/scripts/stow-bin.sh --nosudo
fi
# Stow dotfiles
bin/scripts/stow-dotfiles.sh config

popd >/dev/null || exit 1
bind -f ~/.inputrc
source ~/.bash_profile
