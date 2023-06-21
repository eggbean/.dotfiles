#!/bin/bash

##  Usage: [sudo] stow-bin.sh [--nosudo] [--unstow]
##
##  --nosudo      Stow/restow/unstow in ~/.local for non-sudoer user
##  --unstow      Unstow
##
##  This script does not delete any existing files

set -eo pipefail

options=$(getopt -o '' --long nosudo --long unstow -- "$@")
eval set -- "$options"

while true; do
  case "$1" in
    --nosudo)
      nosudo=true
      ;;
    --unstow)
      unstow=true
      ;;
    --)
      shift
      break
      ;;
  esac
  shift
done

if [ "$(id -u)" = "0" ]; then
  if [ -n "$SUDO_USER" ]; then
    USER="$SUDO_USER"
  else
    USER="$(logname)"
  fi
  HOME="/home/$USER"
  XDG_STATE_HOME="/home/$USER/.local/state"
fi

STOW_DIR="$HOME/.dotfiles/bin"

# Set variables for (re)stowing or unstowing
if [ -n "$unstow" ]; then
  stowcom='-D'
  stowed='unstowed'
  rm "$XDG_STATE_HOME"/binaries_stowed
else
  stowcom='-R'
  stowed='stowed'
  if [ ! -d "$XDG_STATE_HOME" ]; then mkdir -p "$XDG_STATE_HOME"; fi
  touch "$XDG_STATE_HOME"/binaries_stowed
fi

# Set variables for target locations and make directories if necessary
if [ -n "$nosudo" ]; then
  targetdir="$HOME/.local/bin"
  mandir="$HOME/.local/share/man"
  bashcompdir="$HOME/.local/share/bash-completion/completions"
  zshcompdir="$HOME/.local/share/zsh/site-functions"
  fontdir="$HOME/.local/share/fonts"
else
  if [ "$(id -u)" -ne "0" ]; then
    echo "This script must be run as root to stow in /usr, or use the --nosudo option to stow in ~/.local." >&2
    exit 1
  fi
  targetdir='/usr/local/bin'
  mandir='/usr/local/share/man'
  bashcompdir='/usr/local/share/bash-completion/completions'
  zshcompdir="/usr/local/share/zsh/site-functions"
  fontdir='/usr/local/share/fonts'
fi

# If stowing, make target directories if they don't exist
if [ -z "$unstow" ]; then
  for d in "$targetdir" "$mandir" "$bashcompdir" "$zshcompdir" "$fontdir"; do
    if [ ! -d "$d" ]; then mkdir -p "$d"; fi
  done
  if [ -d "$HOME/.dotfiles/bin/man" ]; then
    pushd "$HOME/.dotfiles/bin/man" >/dev/null
    mansubs=(*) && popd >/dev/null
    for s in "${mansubs[@]}"; do
      if [ ! -d "$mandir"/"$s" ]; then mkdir "$mandir"/"$s"; fi
    done
  fi
fi

# Use the correct binaries for CPU architecture
if [ "$(uname -o)" = "Android" ]; then
  [ "$(dpkg --print-architecture)" = "aarch64" ] && arch='android' || { echo "CPU architecture unknown" >&2; exit 1; }
else
  [ "$(arch)" = "armv7l" ] && arch='armv7l'
  [ "$(arch)" = "aarch64" ] && arch='aarch64'
  [ "$(arch)" = "x86_64" ] && arch='x86_64'
  [ -z "$arch" ] && { echo "CPU architecture unknown" >&2; exit 1; }
fi

pushd "$STOW_DIR" >/dev/null

# Stow/unstow binaries
stow $stowcom -vt "$targetdir" "$arch" 2>"${TMPDIR:-/tmp}"/stow-bin.sh.log

# Stow/unstow shell scripts
stow $stowcom -vt "$targetdir" scripts 2>>"${TMPDIR:-/tmp}"/stow-bin.sh.log

# Stow/unstow man files
pushd "$STOW_DIR/man" >/dev/null
mansubs=(*)
for m in "${mansubs[@]}"; do
  stow $stowcom -vt "$mandir"/"$m" "$m" 2>>"${TMPDIR:-/tmp}"/stow-bin.sh.log
done
popd >/dev/null

# Stow/unstow bash completion files
stow $stowcom -vt "$bashcompdir" bash-completions 2>>"${TMPDIR:-/tmp}"/stow-bin.sh.log

# Stow/unstow zsh completion files
stow $stowcom -vt "$zshcompdir" zsh-completions 2>>"${TMPDIR:-/tmp}"/stow-bin.sh.log

# Stow/unstow fonts if local desktop system, but not on WSL
if [ -n "$DISPLAY" ] && grep -vqi microsoft /proc/version; then
  stow --no-folding $stowcom -vt "$fontdir" fonts 2>>"${TMPDIR:-/tmp}"/stow-bin.sh.log
  fc-cache -f
fi

# Clean up any empty directories when unstowing
if [ -n "$unstow" ]; then
  pushd man >/dev/null
  mansubs=(*) && popd >/dev/null
    for r in "${mansubs[@]}"; do
      if [ -d "$mandir"/"$r" ]; then rmdir --ignore-fail-on-non-empty "$mandir"/"$r"; fi
    done
  for e in "$targetdir" "$mandir" "$bashcompdir" "$zshcompdir" "$fontdir"; do
    if [ -d "$e" ]; then rmdir -p --ignore-fail-on-non-empty "$e"; fi
  done
fi
