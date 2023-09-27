#!/bin/bash -e

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
[[ -e $XDG_STATE_HOME/hashicorp_repo_installed ]] && exit 125

eval "$(source /etc/os-release && typeset -p ID)"
if [[ $ID =~ ^(rhel|fedora.*|amzn|ol|rocky|almalinux)$ ]]; then
  if [[ $ID =~ ^(rhel|ol|rocky|almalinux)$ ]]; then release=RHEL; fi
  if [[ $ID =~ ^(fedora.*)$ ]]; then release=fedora; fi
  if [[ $ID == amzn ]]; then release=AmazonLinux; fi
  if [[ -z $release ]]; then { echo ERROR >&2; exit 22; }; fi
  { dnf install -y dnf-plugins-core && \
    dnf config-manager --add-repo https://rpm.releases.hashicorp.com/$release/hashicorp.repo; } || \
    { echo Adding Hashicorp repository failed >&2; exit 1; }
elif [[ $ID =~ ^(debian|ubuntu|pop|linuxmint|raspbian)$ ]]; then
  { apt-get update && apt-get install -y gnupg software-properties-common curl && \
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > \
    /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    sh -c "printf 'deb\t[signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg]\t \
      https://apt.releases.hashicorp.com\t$(lsb_release -cs)\tmain\n' > \
      /etc/apt/sources.list.d/hashicorp.list"; } || \
    { echo Adding Hashicorp repository failed >&2; exit 1; }
else
    { echo OS not supported by Hashicorp repository installation script >&2; exit 95; }
fi

touch $XDG_STATE_HOME/hashicorp_repo_installed
