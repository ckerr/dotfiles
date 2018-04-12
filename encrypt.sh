#/usr/bin/env bash

tar --create --to-stdout assets | openssl enc -aes-256-cbc -e -a -out assets.tar.aes256
