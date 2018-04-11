#!/usr/bin/env bash

BREW_APPS=( syncthing mpv vim macvim xz )

CASK_APPS=( atom font-awesome-terminal-fonts keepassxc meld vagrant vagrant-manager virtualbox virtualbox-extension-pack )


if [ "Darwin" == "$(uname -s)" ]; then

  # install brew if we don't have it already
  item="brew"
  if [ "" == $(command -v ${item}) ]; then
    echo "installing $item"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
      error "error installing $item -> quitting setup"
      exit 2
    fi
  fi

  # update brew
  echo "updating $item"
  $item doctor
  $item update

  # install brew apps
  for app in "${BREW_APPS[@]}"
  do
    brew install $app
    if [[ $? != 0 ]]; then
      error "failed to install $app! aborting..."
      exit -1
    fi
  done

  # install cask
  brew tap caskroom/cask

  # install apps
  for app in "${CASK_APPS[@]}"
  do
    brew cask install $app
    if [[ $? != 0 ]]; then
      error "failed to install $app! aborting..."
      exit -1
    fi
  done

fi
