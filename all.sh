#/usr/bin/env bash

./install-apt.sh
./install-snap.sh
./install-brew.sh
./install-pip3.sh

# need to install oh-my-zsh for nvm before installing npm packages
./decrypt.sh
./install-omz.sh
./install-npm.sh

./setup-stman.sh
./setup-pianobar.sh
