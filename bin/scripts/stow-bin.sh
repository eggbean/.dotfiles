#!/bin/bash

##  Usage: [sudo] stow-bin.sh [--nosudo] [--remove]
##
##  --nosudo      Stow/restow/unstow in ~/.local for non-sudoer user
##  --remove      Unstow
##
##  This script does not delete any existing files

# shellcheck disable=SC2015
# (if the echoes fail something strange is happening and I would want to know about it)

set -eo pipefail

options=$(getopt -o '' --long nosudo --long remove -- "$@")
eval set -- "$options"

while true; do
  case "$1" in
  --nosudo)
    nosudo=true
    ;;
  --remove)
    remove=true
    ;;
  --)
    shift
    break
    ;;
  esac
  shift
done

[ "$(id -u)" = "0" ] && HOME="/home/$SUDO_USER"
STOW_DIR="$HOME/.dotfiles/bin"

# Set variables for (re)stowing or unstowing
if [ -n "$remove" ]; then
  stowcom='-D'
  stowed='unstowed'
  stowing='unstowing'
else
  stowcom='-R'
  stowed='stowed'
  stowing='stowing'
fi

# Set variables for target locations and make directories if necessary
if [ -n "$nosudo" ]; then
  targetdir="$HOME/.local/bin"
  mandir="$HOME/.local/share/man"
  compdir="$HOME/.local/share/bash-completion/completions"
  fontdir="$HOME/.local/share/fonts"
  if [ -z "$remove" ]; then
    for d in "$targetdir" "$mandir" "$compdir" "$fontdir"; do
      if [ ! -d "$d" ]; then mkdir -p "$d"; fi
    done
    if [ -d "$HOME/.dotfiles/bin/man" ]; then
      pushd "$HOME/.dotfiles/bin/man" >/dev/null
      mansubs=(*) && popd >/dev/null
      for s in "${mansubs[@]}"; do
        if [ ! -d "$mandir"/"$s" ]; then mkdir -p "$mandir"/"$s"; fi
      done
    fi
  fi
else
  if [ "$(id -u)" -ne "0" ]; then { echo "This script must be run as root to stow in /usr, or use the --nosudo option to stow in ~/.local." >&2; exit 1; }; fi
  targetdir='/usr/local/bin'
  mandir='/usr/local/share/man'
  compdir='/usr/share/bash-completion/completions'
  fontdir='/usr/local/share/fonts'
fi

# Use the correct binaries for the CPU architecture
if [ "$(uname -o)" = "Android" ]; then
  [ "$(dpkg --print-architecture)" = "aarch64" ] && arch='android'
else
  [ "$(arch)" = "armv7l" ] && arch='armv7l'
  [ "$(arch)" = "aarch64" ] && arch='aarch64'
  [ "$(arch)" = "x86_64" ] && arch='x86_64'
  [ -z "$arch" ] && { echo "CPU architecture unknown" >&2; exit 1; }
fi

pushd "$STOW_DIR" >/dev/null

# Stow/unstow binaries
stow $stowcom -vt "$targetdir" "$arch" 2>&1 \
  && echo "DONE: bin package $stowed" || { echo "ERROR $stowing bin package" >&2; exit 1; }

# Stow/unstow scripts
stow $stowcom -vt "$targetdir" scripts 2>&1 \
  && echo "DONE: scripts package $stowed" || { echo "ERROR $stowing scripts package" >&2; exit 1; }

# Stow/unstow man files
pushd "$STOW_DIR/man" >/dev/null
mansubs=(*)
for m in "${mansubs[@]}"; do
  if [ ! -d "$mandir"/"$m" ]; then mkdir "$mandir"/"$m"; fi
  stow $stowcom -vt "$mandir"/"$m" "$m" 2>&1 \
    && echo "DONE: $m package $stowed" || { echo "ERROR $stowing $m package - possible conflict with existing file(s)" >&2; exit 1; }
done
popd >/dev/null

# Stow/unstow bash completion files
stow $stowcom -vt "$compdir" completions 2>&1 \
  && echo "DONE: bash completions package $stowed" || { echo "ERROR $stowing bash completions package" >&2; exit 1; }

# Stow/unstow fonts if local desktop system, but not on WSL
if [ -n "$DISPLAY" ] && grep -vqi microsoft /proc/version; then
  if [ ! -d "$fontdir" ]; then mkdir -p "$fontdir"; fi
  stow --no-folding $stowcom -vt "$fontdir" fonts 2>&1 \
    && echo "DONE: fonts package $stowed" || { echo "ERROR $stowing fonts package" >&2; exit 1; }
  fc-cache -f && echo "DONE: font cache updated"
fi

# Clean up any empty directories in ~/.local if using --nosudo and --remove switches
if [ -n "$nosudo" ] && [ -n "$remove" ]; then
  pushd man >/dev/null
  mansubs=(*) && popd >/dev/null
    for r in "${mansubs[@]}"; do
      if [ -d "$mandir"/"$r" ]; then rmdir --ignore-fail-on-non-empty "$mandir"/"$r"; fi
    done
  for e in "$targetdir" "$mandir" "$compdir" "$fontdir"; do
    if [ -d "$e" ]; then rmdir -p --ignore-fail-on-non-empty "$e"; fi
  done
fi

exit
