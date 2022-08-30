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
  elinks \
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
