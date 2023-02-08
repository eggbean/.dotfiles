#!/bin/bash

# Install termux packages
yes | pkg update && pkg upgrade && \
yes | pkg install \
  bat \
  cmatrix \
  direnv \
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
  termux-exec \
  terraform \
  tmux \
  traceroute \
  tree \
  tsu \
  wget \
  whois
