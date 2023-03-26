#!/bin/bash -e

# This bootstrap script should be sourced, not executed

pushd ~/.dotfiles >/dev/null || exit 1

eval "$(. /etc/os-release && typeset -p ID)"
if [ "$ID" == "ol" ]; then
  sudo dnf config-manager --set-enabled ol9_developer_EPEL
  sudo dnf upgrade -y
  sudo dnf install -y git htop shellcheck stow tree
elif [ "$ID" == "debian" ]; then
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get install -y git htop shellcheck stow tree
fi

# Stow binaries
if [ "$UID" -ne 0 ] && [ "$EUID" -ne 0 ]; then
  sudo bin/scripts/stow-bin.sh
else
  bin/scripts/stow-bin.sh --nosudo
fi
# Stow dotfiles
bin/scripts/stow-dotfiles.sh config

git remote update

popd >/dev/null || exit 1
bind -f ~/.inputrc
source ~/.bash_profile
