#/usr/bin/env bash

openssl enc -aes-256-cbc -d -a -in assets.tar.aes256 --md sha2565 | tar --extract
