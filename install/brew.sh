#!/usr/bin/env bash

BREW_APPS=(
  coreutils
  golang
  git
  htop
  kpcli
  macvim
  mpv
  openssl
  pianobar
  python3
  ripgrep
  rust
  vim
  xz
)

BREW_SERVICES=(
  syncthing
)

CASK_APPS=(
  atom
  beyond-compare
  font-awesome-terminal-fonts
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
if [ "Darwin" != "$(uname -s)" ]; then
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

function brew_install()
{
  item=$1

  count="$(brew list -1 | grep --count $item)"
  if [ "0" -eq "${count}" ]; then
    brew install "${item}"
    exit_if_error "${item}"
  else
    echo "already installed: ${item}"
  fi
}

function cask_install()
{
  item=$1

  count="$(brew cask list -1 | grep --count $item)"
  if [ "0" -eq "${count}" ]; then
    brew cask install "${item}"
    exit_if_error "${item}"
  else
    echo "already installed: ${item}"
  fi
}

##
##

# ensure brew is installed
item="brew"
if [ "" == "$(command -v ${item})" ]; then
  echo "installing $item"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  exit_if_error $item
fi

# update brew
echo "updating brew"
brew prune
brew doctor
brew update

# install brew apps
for item in "${BREW_APPS[@]}"
do
  brew_install $item
done

# install brew services
for item in "${BREW_SERVICES[@]}"
do
  brew_install $item
  brew services start $item
done

# install cask
brew tap caskroom/cask

# install cask apps
for item in "${CASK_APPS[@]}"
do
  cask_install $item
done
