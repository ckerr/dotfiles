#/usr/bin/env bash

tar --create --to-stdout assets/private/ | openssl enc -aes-256-cbc -e -a -out assets-private.tar.aes256
