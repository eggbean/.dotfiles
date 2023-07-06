#!/bin/bash -e

[ "$(id -u)" -ne "0" ] && { echo "This script must be run as root" >&2; exit 1; }

if [ -n "$SUDO_USER" ]; then
  USER="$SUDO_USER"
else
  USER="$(logname)"
fi
XDG_CACHE_HOME="/home/$USER/.cache"
XDG_STATE_HOME="/home/$USER/.local/state"

rm -rf /etc/nix
rm -rf /nix/
rm -rf /etc/nix
rm -rf ~/.nix-channels ~/.nix-defexpr ~/.nix-profile

rm -rf "$XDG_CACHE_HOME/nix"
rm -rf "$XDG_STATE_HOME/nix"
rm -f "$XDG_STATE_HOME/nix_packages"
