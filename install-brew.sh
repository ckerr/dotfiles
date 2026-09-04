#!/usr/bin/env bash

set -uo pipefail

BREW_APPS=(
  a2ps
  cmake
  coreutils
  direnv
  findutils
  fzy
  git
  golang
  htop
  kpcli
  lesspipe
  mpv
  ninja
  openssl
  pandoc
  pv
  python3
  ripgrep
  vim
  vlc
  wget
  xz
  yarn
  zsh
)
  #valgrind

BREW_SERVICES=(
  syncthing
)

CASK_APPS=(
  beyond-compare
  font-fira-code
  font-fira-mono-for-powerline
  keepassxc
  meld
  vagrant
  vagrant-manager
  virtualbox
  virtualbox-extension-pack
)

##
##

# we only need this file on mac
if [[ "${OSTYPE}" != *darwin* ]]; then
  exit 0
fi

##
##

# ensure brew is installed
if ! command -v brew > /dev/null 2>&1; then
  echo 'installing brew'
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || { echo 'brew install failed! aborting...'; exit 1; }
fi

# update brew
echo 'updating brew'
brew update
brew upgrade
brew upgrade --cask

brew install "${BREW_APPS[@]}"

# install brew services
brew install "${BREW_SERVICES[@]}"
brew services restart --all

# install cask apps. caskroom/cask was renamed homebrew/cask in 2018 and
# is auto-tapped by brew now, so there is nothing left to tap by hand.
brew install --cask "${CASK_APPS[@]}"

# clean up after ourselves
brew cleanup -s

# show some diagnostics
brew doctor
brew missing

echo "$0 done"
