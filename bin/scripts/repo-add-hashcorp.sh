#!/bin/bash

if [[ $(id -u) != 0 ]]; then
  { echo "This script must be run as root." >&2; exit 1; }
elif [[ -n $SUDO_USER ]]; then
  USER="$SUDO_USER"
else
  USER="$(logname)"
fi
if [[ -z $XDG_STATE_HOME ]]; then
  export XDG_STATE_HOME="/home/$USER/.local/state"
fi
[[ -e $XDG_STATE_HOME/hashicorp_repo_installed ]] && exit 1

eval "$(source /etc/os-release && typeset -p ID)"
if [[ $ID =~ ^(rhel|fedora|amzn|ol|rocky)$ ]]; then
  { dnf install -y dnf-plugins-core && \
    dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo; } || \
    { echo Adding Hashicorp repository failed >&2; exit 1; }
elif [[ $ID =~ ^(debian|ubuntu|pop|raspbian)$ ]]; then
  { apt-get update && apt-get install -y gnupg software-properties-common curl && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    sh -c "printf 'deb\t[arch=amd64]\thttps://apt.releases.hashicorp.com\t$(lsb_release -cs)\tmain\n' \
    > /etc/apt/sources.list.d/hashicorp.list"; } || \
    { echo Adding Hashicorp repository failed >&2; exit 1; }
else
    { echo OS not supported by Hashicorp repository installation script >&2; exit 1; }
fi

touch $XDG_STATE_HOME/hashicorp_repo_installed
