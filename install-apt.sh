#!/usr/bin/env bash

# cpplint

UBUNTU_APPS=(
  a2ps
  aptitude
  atom
  cargo
  clang-format
  cmake
  cowsay
  cppreference-doc-en-html
  devhelp
  execstack
  fdupes
  flac
  flake8
  fonts-firacode
  fonts-inconsolata
  fonts-powerline
  fslint
  fzy
  gconf-editor
  git
  gnome-tweak-tool
  google-chrome-stable
  meld
  mpv
  ninja-build
  openssl
  opus-tools
  pianobar
  pngquant
  powerstat
  python3-pip
  rename
  sox
  tig
  transmission-cli
  transmission-daemon
  valgrind
  vim
  vim-gtk3
  xclip
  zsh
  zsh-doc
)

##
##


# this script is for systems that have apt
if [ "" == "$(command -v apt-get)" ]; then
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

function add_repo()
{
  key_url=$1
  repo_url=$2
  list_file=$3

  if [ ! -f "${list_file}" ]; then
    wget -q -O - "${key_url}" | sudo apt-key add -
    echo "deb [arch=amd64] ${repo_url} any main" | sudo tee "${list_file}"
  fi
}

function apt_install()
{
  item=$1
  #echo $item

  dpkg -s "${item}" > /dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo "already installed: ${item}"
  else
    echo "installing ${item}"
    sudo apt-get --yes install --install-suggests "${item}"
    exit_if_error "${item}"
  fi
}

## Add some repos

add_repo "https://packagecloud.io/AtomEditor/atom/gpgkey" \
         "https://packagecloud.io/AtomEditor/atom/any/" \
         "/etc/apt/sources.list.d/atom.list"

add_repo "https://dl-ssl.google.com/linux/linux_signing_key.pub" \
         "http://dl.google.com/linux/chrome/deb/" \
         "/etc/apt/sources.list.d/google-chrome.list"

sudo add-apt-repository --no-update --yes ppa:transmissionbt/ppa


## Install some packages

sudo apt update
sudo apt --yes full-upgrade
for item in "${UBUNTU_APPS[@]}"
do
  apt_install $item
done
sudo apt autoremove
sudo apt-get clean

