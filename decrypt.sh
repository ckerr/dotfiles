#/usr/bin/env sh

openssl enc -aes-256-cbc -d -a -in assets-private.tar.aes256 -md sha256 | tar --extract
