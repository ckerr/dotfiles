#!/usr/bin/env bash

BREW_APPS=(
  a2ps
  coreutils
  direnv
  findutils
  fzy
  git
  golang
  htop
  kpcli
  mpv
  openssl
  pandoc
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
  atom
  beyond-compare
  font-awesome-terminal-fonts
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

function exit_if_error()
{
  if [[ $? != 0 ]]; then
    echo "$1 failed! aborting..."
    exit 1
  fi
}

##
##

# ensure brew is installed
item='brew'
if [ "" == "$(command -v ${item})" ]; then
  echo "installing $item"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  exit_if_error $item
fi

# update brew
echo 'updating brew'
brew update
brew upgrade
brew cask upgrade

brew install "${BREW_APPS[@]}"

# install brew services
brew install "${BREW_SERVICES[@]}"
brew services restart --all

# install cask
brew tap caskroom/cask

# install cask apps
brew cask install "${CASK_APPS[@]}"

# clean up after ourselves
brew cleanup -s
brew cask cleanup

# show some diagnostics
brew doctor
brew cask doctor
brew missing
