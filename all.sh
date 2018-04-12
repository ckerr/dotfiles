#/usr/bin/env bash

install/apt.sh
install/snap.sh
install/brew.sh
install/pip3.sh

# need to install oh-my-zsh for nvm before installing npm packages
./decrypt.sh
install/zsh.sh
install/npm.sh

#all.sh
#popd
#
#pushd settings
#  ./decrypt.sh
#popd

#pushd install
#zsh.sh
#popd

#setup/all.sh
