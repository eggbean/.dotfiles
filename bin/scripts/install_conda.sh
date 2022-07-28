#!/bin/bash

install_dir=$HOME/miniconda3

if [ ! -d ${install_dir} ]; then
    case "$OSTYPE" in
        darwin*)  os=MacOSX ;;
        linux*)   os=Linux ;;
    esac

    url=https://repo.anaconda.com/miniconda/Miniconda3-latest-${os}-$(uname -m).sh
    tmp_script=/tmp/miniconda.sh

    curl $url --output $tmp_script
    bash $tmp_script -b -p ${install_dir}
    rm -f $tmp_script
else
    echo "miniconda is installed, skipping"
fi
