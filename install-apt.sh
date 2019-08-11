#!/usr/bin/env bash

# cpplint

declare -r UBUNTU_APPS=(
  a2ps
  advancecomp
  aptitude
  atom
  build-essential
  cargo
  clang-format
  cmake
  code
  cowsay
  cppcheck
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
  golang
  google-chrome-stable
  htop
  keepassxc
  meld
  mpv
  ninja-build
  openssl
  opus-tools
  pandoc
  pngcrush
  pngquant
  powerstat
  powertop
  python-dbusmock
  python3-chardet
  python3-dbusmock
  python3-dev
  python3-pip
  rename
  sox
  tig
  tmux
  transmission-cli
  transmission-daemon
  unrar
  valgrind
  vim
  vim-gtk3
  vlc
  xclip
  yarn
  zeal
  zopfli
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
  local key_url="${1}"
  local repo_url="${2}"
  local list_file="${3}"
  local suite="${4-stable}"
  local component="${5-main}"
  local arch=$(dpkg --print-architecture)

  if [ ! -f "${list_file}" ]; then
    wget -q -O - "${key_url}" | sudo apt-key add -
    echo "deb [arch=${arch}] ${repo_url} ${suite} ${component}" | sudo tee "${list_file}"
  fi
}

function apt_install()
{
  local item="${1}"
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

add_repo 'https://dl-ssl.google.com/linux/linux_signing_key.pub' \
         'http://dl.google.com/linux/chrome/deb/' \
         '/etc/apt/sources.list.d/google-chrome.list' \
         'stable' 'main'

# source: https://github.com/microsoft/vscode/issues/2973#issuecomment-280575841
add_repo 'https://packages.microsoft.com/keys/microsoft.asc' \
         'https://packages.microsoft.com/repos/vscode' \
         '/etc/apt/sources.list.d/vscode.list' \
         'stable' 'main'

# https://keepassxc.org/blog/2017-10-25-ubuntu-ppa/
sudo add-apt-repository --no-update --yes ppa:phoerious/keepassxc

# disabling 2019-07-11 because Disco not supported yet
#sudo add-apt-repository --no-update --yes ppa:transmissionbt/ppa

## Install some packages

sudo apt update
sudo apt --yes full-upgrade
for item in "${UBUNTU_APPS[@]}"
do
  apt_install $item
done
sudo apt autoremove
sudo apt-get clean

