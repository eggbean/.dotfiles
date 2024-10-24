#!/bin/bash

# This is a modified version of my eza-wrapper.sh script (https://bit.ly/eza-wrapper)
# which has a couple of conditional tweaks for use on Windows Subsystem for Linux

## Change following to '0' for output to be like ls and '1' for eza features
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
          if [[ $no_eza_git =~ true ]]; then git=0; else git=1; fi
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

eza_opts=()

while getopts ':aAbtucSI:rkhnsXL:MNg1lFGRdDioTx@' arg; do
  case $arg in
    a) (( dot == 1 )) && eza_opts+=(-a) || eza_opts+=(-a -a) ;;
    A) eza_opts+=(-a) ;;
    t) eza_opts+=(-s modified); ((++rev)) ;;
    u) eza_opts+=(-us accessed); ((++rev)) ;;
    c) eza_opts+=(-Us created); ((++rev)) ;;
    S) eza_opts+=(-s size); ((++rev)) ;;
    I) eza_opts+=(--ignore-glob="${OPTARG}") ;;
    r) ((++rev)) ;;
    k) ((--hru)) ;;
    h) ((++hru)) ;;
    n) eza_opts+=(--git-ignore) ;;
    s) eza_opts+=(-S) ;;
    X) eza_opts+=(-s extension) ;;
    L) eza_opts+=(--level="${OPTARG}") ;;
    o) eza_opts+=(--octal-permissions) ;;
    M) ((++gpd)) ;;
    N) ((++nco)) ;;
    g) ((++git)) ;;
    b) ((--meb)) ;;
    1|l|F|G|R|d|D|i|T|x|@) eza_opts+=(-"$arg") ;;
    :) printf "%s: -%s switch requires a value\n" "${0##*/}" "${OPTARG}" >&2; exit 1
       ;;
    *) printf "Error: %s\n       --help for help\n" "${0##*/}" >&2; exit 1
       ;;
  esac
done

shift "$((OPTIND - 1))"

(( rev == 1 )) && eza_opts+=(-r)
(( fgp == 0 )) && eza_opts+=(-g)
(( lnk == 0 )) && eza_opts+=(-H)
(( hru <= 0 )) && eza_opts+=(-B)
(( hed == 1 )) && eza_opts+=(-h)
(( meb == 0 && hru > 0 )) && eza_opts+=(-b)
(( col == 1 )) && eza_opts+=(--color=always) || eza_opts+=(--color=auto)
(( nco == 1 )) && eza_opts+=(--color=never)
(( gpd >= 1 )) && eza_opts+=(--group-directories-first)
(( ico == 1 )) && eza_opts+=(--icons)
(( git == 1 )) && \
  [[ $(git -C ${*:-.} rev-parse --is-inside-work-tree) == true ]] 2>/dev/null && eza_opts+=(--git)

# Test for variable set by direnv to ignore desktop.ini
# and registry files on NTFS shared partitions
[[ $eza_ignore =~ true ]] && eza_opts+=(-I "desktop.ini|ntuser.*|NTUSER.*")

# Use my patched version of eza on NTFS drives so that files
# aren't all seen as executables, so appear in $LS_COLORS.
if grep -qi microsoft /proc/version 2>/dev/null; then
  shopt -s extglob
  [[ $(realpath ${*:-.}) == /@(mnt|?)/* ]] 2>/dev/null && ezabin=exa-ntfs || ezabin=eza
fi

${ezabin:-eza} --color-scale "${eza_opts[@]}" "$@"
