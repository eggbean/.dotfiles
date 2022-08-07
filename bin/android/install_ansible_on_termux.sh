#!/bin/bash

yes | pkg upgrade && \
yes | pkg install \
	openssl python rust build-essential
pip install --upgrade pip setuptools wheel
export CARGO_BUILD_TARGET=aarch64-linux-android
pip install --upgrade cryptography ansible pywinrm[credssp]
