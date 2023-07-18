#!/bin/bash

# This is a modified version of my exa-wrapper.sh script (https://bit.ly/exa-wrapper)
# which has a couple of conditional tweaks for use on Windows Subsystem for Linux

## Change following to '0' for output to be like ls and '1' for exa features
# Don't list implied . and .. by default with -a
dot=0
# Show human readable file sizes by default
hru=1
# Show file sizes in decimal (1KB=1000 bytes) as opposed to binary units (1KiB=1024 bytes)
meb=0
# Don't show group column
fgp=0
# Don't show hardlinks column
lnk=0
# Show file git status automatically (can cause a slight delay in large repo trees)
git=1     # Replacing with test for variable set by direnv
          # as git for Linux is very slow on NTFS
          if [[ $no_exa_git =~ true ]]; then git=0; else git=1; fi
# Show icons
ico=0
# Show column headers
hed=0
# Group directories first in long listing by default
gpd=0
# Colour always even when piping (can be disabled with -N switch when not wanted)
col=1

help() {
    cat << EOF
  ${0##*/} options:
   -a  all
   -A  almost all
   -1  one file per line
   -x  list by lines, not columns
   -l  long listing format
   -G  display entries as a grid *
   -k  bytes
   -h  human readable file sizes
   -F  classify
   -R  recurse
   -r  reverse
   -d  don't list directory contents
   -D  directories only *
   -M  group directories first *
   -I  ignore [GLOBS]
   -i  show inodes
   -o  show octal permissions *
   -N  no colour *
   -S  sort by file size
   -t  sort by modified time
   -u  sort by accessed time
   -c  sort by created time *
   -X  sort by extension
   -T  tree *
   -L  level [DEPTH] *
   -s  file system blocks
   -g  don't show/show file git status *
   -n  ignore .gitignore files *
   -b  file sizes in binary/decimal (--si in ls)
   -@  extended attributes and sizes *

    * not used in ls
EOF
    exit
}

[[ $* =~ --help ]] && help

exa_opts=()

while getopts ':aAbtucSI:rkhnsXL:MNg1lFGRdDioTx@' arg; do
  case $arg in
    a) (( dot == 1 )) && exa_opts+=(-a) || exa_opts+=(-a -a) ;;
    A) exa_opts+=(-a) ;;
    t) exa_opts+=(-s modified); ((++rev)) ;;
    u) exa_opts+=(-us accessed); ((++rev)) ;;
    c) exa_opts+=(-Us created); ((++rev)) ;;
    S) exa_opts+=(-s size); ((++rev)) ;;
    I) exa_opts+=(--ignore-glob="${OPTARG}") ;;
    r) ((++rev)) ;;
    k) ((--hru)) ;;
    h) ((++hru)) ;;
    n) exa_opts+=(--git-ignore) ;;
    s) exa_opts+=(-S) ;;
    X) exa_opts+=(-s extension) ;;
    L) exa_opts+=(--level="${OPTARG}") ;;
    o) exa_opts+=(--octal-permissions) ;;
    M) ((++gpd)) ;;
    N) ((++nco)) ;;
    g) ((++git)) ;;
    b) ((--meb)) ;;
    1|l|F|G|R|d|D|i|T|x|@) exa_opts+=(-"$arg") ;;
    :) printf "%s: -%s switch requires a value\n" "${0##*/}" "${OPTARG}" >&2; exit 1
       ;;
    *) printf "Error: %s\n       --help for help\n" "${0##*/}" >&2; exit 1
       ;;
  esac
done

shift "$((OPTIND - 1))"

(( rev == 1 )) && exa_opts+=(-r)
(( fgp == 0 )) && exa_opts+=(-g)
(( lnk == 0 )) && exa_opts+=(-H)
(( hru <= 0 )) && exa_opts+=(-B)
(( hed == 1 )) && exa_opts+=(-h)
(( meb == 0 && hru > 0 )) && exa_opts+=(-b)
(( col == 1 )) && exa_opts+=(--color=always) || exa_opts+=(--color=auto)
(( nco == 1 )) && exa_opts+=(--color=never)
(( gpd >= 1 )) && exa_opts+=(--group-directories-first)
(( ico == 1 )) && exa_opts+=(--icons)
(( git == 1 )) && \
  [[ $(git -C ${*:-.} rev-parse --is-inside-work-tree) == true ]] 2>/dev/null && exa_opts+=(--git)

# Test for variable set by direnv to ignore desktop.ini
# and registry files on NTFS shared partitions
[[ $exa_ignore =~ true ]] && exa_opts+=(-I "desktop.ini|ntuser.*|NTUSER.*")

# Use my patched version of exa on NTFS drives so that files
# aren't all seen as executables, so appear in $LS_COLORS.
if grep -qi microsoft /proc/version; then
  shopt -s extglob
  [[ $(realpath ${*:-.}) == /@(mnt|?)/* ]] 2>/dev/null && exabin=exa-ntfs || exabin=exa
fi

${exabin:-exa} --color-scale "${exa_opts[@]}" "$@"
