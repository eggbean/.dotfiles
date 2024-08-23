#!/bin/bash

# Install termux packages
yes | pkg update && \
yes | pkg upgrade && \
yes | pkg install \
  bat \
  broot \
  curl \
  direnv \
  dnsutils \
  dust \
  expect \
  eza \
  file \
  fzf \
  gh \
  git-crypt \
  git-delta \
  glow \
  gnupg \
  gum \
  hyperfine \
  inetutils \
  iproute2 \
  jq \
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
  tergent \
  termux-api \
  termux-exec \
  tmux \
  traceroute \
  tree \
  tsu \
  vim \
  w3m \
  wget \
  which \
  whois \
  zoxide \
  zsh \
  zsh-completions
