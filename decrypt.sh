#/usr/bin/env sh

openssl enc -aes-256-cbc -d -a -pbkdf2 -in assets-private.tar.aes256 -md sha256 | tar --extract
