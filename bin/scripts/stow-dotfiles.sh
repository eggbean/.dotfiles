#!/bin/bash

##  Usage: stow-packages.sh [PACKAGE] [PACKAGE] [PACKAGE]
##
##  ?* section cannot currently handle more than one element in a package
##
##  This script deletes or moves existing files

# shellcheck disable=SC2015,SC2088

[[ "$(id -u)" = "0" ]] && { echo "This script is not supposed to be run as root" >&2; exit 1; }

set -euo pipefail

shopt -s dotglob nullglob

if [ $# -eq 0 ]; then
  echo "No packages provided" >&2
  echo "Usage: ./stow-packages.sh [PACKAGE] [PACKAGE] [PACKAGE]" >&2
  exit 1
fi

pushd ~/.dotfiles > /dev/null

while :; do
  case ${1-} in
    shell)  pushd shell > /dev/null
            shelld=(*)
            popd > /dev/null
            is_file() { local f; for f; do [[ -e ~/"$f" && ! -L ~/"$f" ]] && return; done; return 1; }
            if is_file "${shelld[@]}"; then [ ! -d ~/existing-shell-files ] && mkdir ~/existing-shell-files && echo "~/existing-shell-files directory created"; fi
            for j in "${shelld[@]}"; do
              if [[ -e ~/"$j" && ! -L ~/"$j" ]]; then mv ~/"$j" ~/existing-shell-files && echo "Existing ~/$j file moved to ~/existing-shell-files"; fi
            done
            stow -Rvt ~ shell && echo "DONE: shell package stowed" || { echo "ERROR stowing shell package" >&2; exit 1; }
            ;;
    config) if [ ! -d ~/.local/share ]; then mkdir -p ~/.local/share; fi
            pushd config/.local/share > /dev/null
            locald=(*)
            for m in "${locald[@]}"; do
              if [ -e ~/.local/share/"$m" ] && [ ! -L ~/.local/share/"$m" ]; then rm -rf ~/.local/share/"$m" && echo "Existing ~/.local/share/$m deleted"; fi
            done
            popd > /dev/null
            if [ ! -d ~/.config ]; then mkdir ~/.config; fi
            pushd config/.config > /dev/null
            configd=(*)
            popd > /dev/null
            for i in "${configd[@]}"; do
              if [ -e ~/.config/"$i" ] && [ ! -L ~/.config/"$i" ]; then rm -rf ~/.config/"$i" && echo "Existing ~/.config/$i deleted"; fi
            done
            stow -Rvt ~ config && echo "DONE: config package stowed" || { echo "ERROR stowing config package" >&2; exit 1; }
            ;;
    ssh)    pushd ssh > /dev/null
            sshd=(*)
            find .ssh/ -name 'id_*' ! -name 'id_*.pub' -exec chmod 400 {} \;
            popd > /dev/null
            for s in "${sshd[@]}"; do
              if [ -e ~/.ssh/"$s" ] && [ ! -L ~/.ssh/"$s" ]; then rm ~/.ssh/"$s" && echo "Existing ~/.ssh/$s deleted"; fi
            done
            stow --no-folding -Rvt ~ ssh && echo "DONE: ssh package stowed" || { echo "ERROR stowing ssh package" >&2; exit 1; }
            ;;
    ?*)     pushd "$1"/ > /dev/null || { echo "ERROR finding $1 package" >&2; exit 1; }
            packaged=(*)
            popd > /dev/null
            if [ ${#packaged[@]} -gt 1 ]; then { echo "WARNING: This does not work for packages which contain more than one directory (folded)." >&2; break; }; fi
            for k in "${packaged[@]}"; do
              if [ -e ~/"$k" ] && [ ! -L ~/"$k" ]; then
                while read -rp "Do you want to delete ~/$k and replace it with a stow symlink? (y/n)   " yn; do
                  case $yn in
                    [Yy]* ) rm -rf ~/"$k" && echo "Existing ~/$k file/directory deleted"
                        stow -Svt ~ "$1" && echo "DONE: $1 package stowed" || { echo "ERROR stowing $1 package" >&2; exit 1; }
                        break
                        ;;
                    [Nn]* ) while read -rp "Do you want to stow the $1 package unfolded? (y/n)   " yn; do
                          case $yn in
                            [Yy]* ) stow --no-folding -Svt ~ "$1" && echo "DONE: $1 package stowed" || { echo "ERROR stowing $1 package" >&2; exit 1; }
                                break
                                ;;
                            [Nn]* ) echo "SKIPPED:  $1 package not stowed"
                                break
                                ;;
                            * )   echo "Please answer yes or no"
                                ;;
                          esac
                        done
                        ;;
                      * ) echo "Please answer yes or no"
                        ;;
                  esac
                done
              elif [ ! -e ~/"$k" ] || [ -L ~/"$k" ]; then
                stow -Rvt ~ "$1" && echo "DONE: $1 package stowed" || { echo "ERROR stowing $1 package" >&2; exit 1; }
              fi
            done
            ;;
    *)      break
            ;;
  esac
  shift
done

exit
