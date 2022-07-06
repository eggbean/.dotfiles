#!/bin/bash

yes | pkg upgrade && \
yes | pkg install \
	openssl python rust build-essential
pip install --upgrade pip
pip install --upgrade setuptools
pip install wheel
export CARGO_BUILD_TARGET=aarch64-linux-android
pip install cryptography
pip install ansible
