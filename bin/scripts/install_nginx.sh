#!/bin/bash

# Installs nginx from nginx repository (not distro repo)
#
# Usage:  sudo ./install_nginx.sh [ --stable ]
#         --stable option: Use stable channel instead of mainline
#
# Currently supported:
# RHEL
# CentOS
# Oracle Linux
# AlmaLinux
# Rocky Linux
# Amazon Linux 2023 (NOT Amazon Linux 2)
#
# https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/

if [[ $(id -u) -ne 0 ]]; then
	{ echo "This script must be run as root." >&2; exit 1; }
fi

if [[ $1 =~ --stable ]]; then stable=true; fi

eval "$(source /etc/os-release && typeset -p ID)"

if [[ $ID =~ ^(centos|rhel|ol|almalinux|rocky)$ ]]; then

	systemctl stop nginx 2>/dev/null
	yum remove -y nginx
	yum install yum-utils

	if [[ -f /etc/yum.repos.d/nginx.repo ]]; then
		rm /etc/yum.repos.d/nginx.repo
	fi

	cat <<-'EOF' > /etc/yum.repos.d/nginx.repo
	[nginx-stable]
	name=nginx stable repo
	baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
	gpgcheck=1
	enabled=1
	gpgkey=https://nginx.org/keys/nginx_signing.key
	module_hotfixes=true

	[nginx-mainline]
	name=nginx mainline repo
	baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
	gpgcheck=1
	enabled=0
	gpgkey=https://nginx.org/keys/nginx_signing.key
	module_hotfixes=true
	EOF

	if [[ $stable == true ]]; then
		yum-config-manager --enable nginx-stable
	else
		yum-config-manager --enable nginx-mainline
	fi

	yum update -y
	yum install -y nginx
	nginx
	curl -I 127.0.0.1
	nginx -v

elif [[ $ID =~ ^(amzn)$ ]]; then

	systemctl stop nginx 2>/dev/null
	yum remove -y nginx
	yum install yum-utils

	if [[ -f /etc/yum.repos.d/nginx.repo ]]; then
		rm /etc/yum.repos.d/nginx.repo
	fi

	cat <<-'EOF' > /etc/yum.repos.d/nginx.repo
	[nginx-stable]
	name=nginx stable repo
	baseurl=http://nginx.org/packages/amzn/2023/$basearch/
	gpgcheck=1
	enabled=1
	gpgkey=https://nginx.org/keys/nginx_signing.key
	module_hotfixes=true

	[nginx-mainline]
	name=nginx mainline repo
	baseurl=http://nginx.org/packages/mainline/amzn/2023/$basearch/
	gpgcheck=1
	enabled=0
	gpgkey=https://nginx.org/keys/nginx_signing.key
	module_hotfixes=true
	EOF

	if [[ $stable == true ]]; then
		yum-config-manager --enable nginx-stable
	else
		yum-config-manager --enable nginx-mainline
	fi

	yum update -y
	yum install -y nginx
	nginx
	curl -I 127.0.0.1
	nginx -v

else

	echo "Distro not yet supported by this script!" >&2
	exit 1

fi
