#!/bin/bash -e

[ "$(id -u)" -ne "0" ] && { echo "This script must be run as root" >&2; exit 1; }

if [ -n "$SUDO_USER" ]; then
  USER="$SUDO_USER"
else
  USER="$(logname)"
fi
XDG_STATE_HOME="/home/$USER/.local/state"

rm -rf /nix/
rm -rf /etc/nix
rm -rf ~/.nix-channels ~/.nix-defexpr ~/.nix-profile
if [ -f "$XDG_STATE_HOME/nix_packages" ]; then
  rm "$XDG_STATE_HOME/nix_packages"
fi
