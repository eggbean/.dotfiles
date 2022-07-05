#!/bin/bash

# Install termux packages
yes | pkg update && pkg upgrade && \
yes | pkg install \
	bat \
	cmatrix \
	dnsutils \
	dust \
	exa \
	file \
	fzf \
	gh \
	git-crypt \
	git-delta \
	glow \
	hub \
	hyperfine \
	inetutils \
	iproute2 \
	macchina \
	man \
	mosh \
	ncurses-utils \
	neovim \
	nmap \
	no-more-secrets \
	openssh \
	pastel \
	pigz \
	python \
	rclone \
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

# Install ansible
yes | pkg upgrade && \
yes | pkg install \
	openssl python rust
pip install --upgrade pip
pip install wheel
export CARGO_BUILD_TARGET=aarch64-linux-android
pip install cryptography
pip install ansible
