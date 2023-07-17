#!/bin/bash

yelw=$(tput setaf 3)
norm=$(tput sgr0)

cd /boot || exit 1
shopt -s nullglob ; for file in config-* ; do kernels+=( "${file#config-}" ) ; done
newest="$(printf '%s\n' "${kernels[@]}" | sort -V -t - -k 1,2 | tail -n1)"
current="$(uname -r)"
[[ $current != $newest ]] && echo "${yelw}Reboot needed for new kernel${norm}"
