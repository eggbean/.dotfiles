#!/bin/bash

# Install termux packages
yes | pkg update && pkg upgrade && \
yes | pkg install \
  bat \
  curl \
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
  hyperfine \
  inetutils \
  iproute2 \
  man \
  mosh \
  ncurses-utils \
  neovim \
  nmap \
  openssh \
  pastel \
  python \
  rclone \
  ripgrep \
  starship \
  stow \
  tar \
  termux-api \
  termux-exec \
  terraform \
  tmux \
  traceroute \
  tre \
  tree \
  tsu \
  w3m \
  wget \
  whois