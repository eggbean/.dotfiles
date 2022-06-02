#!/bin/bash

yes | pkg update && pkg upgrade && \
yes | pkg install \
	bat \
	cmatrix \
	dnsutils \
	dust \
	exa \
	file \
	git-crypt \
	git-delta \
	hyperfine \
	inetutils \
	iproute2 \
	man \
	mosh \
	ncurses-utils \
	neovim \
	nmap \
	no-more-secrets \
	openssh \
	pastel \
	pigz \
	ripgrep \
	starship \
	stow \
	termux-api \
	terraform \
	tmux \
	traceroute \
	tree \
	wget \
	whois
