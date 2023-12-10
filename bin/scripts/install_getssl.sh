#!/bin/bash

error_string=("Error: This command has to be run with superuser"
  "privileges (under the root user on most systems).")
if [[ $(id -u) -ne 0 ]]; then echo "${error_string[@]}" >&2; exit 1; fi

eval "$(. /etc/os-release && typeset -p ID)"
if [[ $ID =~ ^(debian|ubuntu)$ ]]; then
  pkg=deb
  apt-get update
  apt-get install -y curl jq
  nameregex='^getssl_\d[\d.]+?-\d+?_all.deb$'
elif [[ $ID =~ ^(rhel|centos|almalinux|amzn|ol|rocky)$ ]]; then
  pkg=rpm
  yum install -y curl jq
  nameregex='^getssl-\d[\d.]+?-\d+?.noarch.rpm$'
else
  echo "Unsupported OS" >&2; exit 1
fi

tag="$(curl -s https://api.github.com/repos/srvrco/getssl/releases/latest | jq -r '.tag_name')"

url="$(curl -s https://api.github.com/repos/srvrco/getssl/releases/latest | \
  jq -r '.assets[] | select(.name|test($name)).browser_download_url' --arg name "${nameregex}")"

wget -q "${url}" -O /tmp/getssl.${pkg} || exit 1

if [[ $pkg == deb ]]; then
  dpkg -i /tmp/getssl.${pkg}
  apt-get install -f -y
else
  rpm -U /tmp/getssl.${pkg}
fi

rm /tmp/getssl.${pkg}
