#!/bin/bash

cd /boot || exit 1
shopt -s nullglob ; for file in config-* ; do kernels+=( "${file#config-}" ) ; done
newest="$(printf '%s\n' "${kernels[@]}" | sort -V -t - -k 1,2 | tail -n1)"
current="$(uname -r)"
[[ $current != $newest ]] && echo "Reboot needed for new kernel"
