#!/usr/bin/env bash

# cpplint
# hotspot

declare -r UBUNTU_APPS=(
  a2ps
  advancecomp
  aptitude
  atomicparsley # used by youtube-dlc in install-pip.sh
  build-essential
  cargo
  clang-format
  clonezilla
  cmake
  code
  cowsay
  cppcheck
  dconf-editor
  debian-goodies # find-dbgsym-packages
  devhelp
  direnv
  execstack
  fdupes
  flac
  flake8
  fonts-cantarell
  fonts-firacode
  fonts-inconsolata
  fonts-powerline
  fzy
  gconf-editor
  gir1.2-appindicator3-0.1 # required by syncthing-gtk for system tray
  git
  gnome-tweak-tool
  gnome-tweaks
  golang
  google-chrome-stable
  gperf
  handbrake
  htop
  keepassxc
  lame
  libreoffice-calc
  linux-cloud-tools-generic
  linux-tools-generic
  locate
  mediainfo
  meld
  mpv
  ncdu
  ninja-build
  openssl
  optipng
  opus-tools
  pandoc
  pngcrush
  pngquant
  powerstat
  powertop
  pv
  python3-chardet
  python3-dbusmock
  python3-dev
  python3-pip
  rename
  ripgrep
  sox
  telegram-desktop
  tig
  tmux
  transmission-cli
  transmission-daemon
  typecatcher
  unrar
  update
  valgrind
  vim
  vim-gtk3
  virtualbox
  virtualbox-qt
  virtualbox-ext-pack
  virtualbox-guest-additions-iso
  vlc
  vorbis-tools
  wajig
  wmctrl # required by vim-shell
  xclip
  xdotool
  zeal
  zopfli
  zsh
  zsh-doc

  # transmission-qt build deps & debugging
  automake
  clang
  clang-tidy
  libcurl4-openssl-dev
  libcurl4-openssl-dev
  libqt5core5a-dbgsym
  libqt5dbus5-dbgsym
  libqt5gui5-dbgsym
  libqt5network5-dbgsym
  libqt5qml5-dbgsym
  libqt5widgets5-dbgsym
  libqwt-qt5-dev
  libssl-dev
  libssl-dev
  libtool
  qt5-default
  qt5-gtk-platformtheme-dbgsym
  qt5-gtk2-platformtheme-dbgsym
  qt5-qmake
  qttools5-dev
  uncrustify
)
declare -r UBUNTU_BUILD_DEPS=(
  pan
  transmission-daemon
  transmission-gtk
  transmission-qt
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

# source: https://www.ubuntuupdates.org/ppa/virtualbox.org_contrib
add_repo 'http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc' \
         'http://download.virtualbox.org/virtualbox/debian' \
         '/etc/apt/sources.list.d/virtualbox.org.list' \
         "$(lsb_release --short --codename)" "non-free contrib"

# source: https://apt.syncthing.net/
add_repo 'https://syncthing.net/release-key.txt' \
         'https://apt.syncthing.net/' \
         '/etc/apt/sources.list.d/syncthing.list' \
         'syncthing' 'stable'

# https://handbrake.fr/downloads.php
sudo add-apt-repository --no-update --yes ppa:stebbins/handbrake-releases

# https://keepassxc.org/blog/2017-10-25-ubuntu-ppa/
sudo add-apt-repository --no-update --yes ppa:phoerious/keepassxc

# https://launchpad.net/~git-core/+archive/ubuntu/ppa
sudo add-apt-repository --no-update --yes ppa:git-core/ppa

# https://github.com/Neroth/gnome-shell-extension-weather
sudo add-apt-repository --no-update --yes ppa:gnome-shell-extensions

sudo apt update

# https://wiki.ubuntu.com/Debug%20Symbol%20Packages
function ensure_ddebs_source_exists {
  local -r filename='/etc/apt/sources.list.d/ddebs.list'
  local -r codename="$(lsb_release --short --codename)"
  if ! grep -q "$codename" "$filename"; then
    echo "updating $filename"
    echo "deb http://ddebs.ubuntu.com $codename main restricted universe multiverse
deb http://ddebs.ubuntu.com $codename-updates main restricted universe multiverse
deb http://ddebs.ubuntu.com $codename-proposed main restricted universe multiverse" | \
    sudo tee "${filename}";
    sudo apt install ubuntu-dbgsym-keyring
  fi
}
ensure_ddebs_source_exists

# disabling 2019-07-11 because Disco not supported yet
#sudo add-apt-repository --no-update --yes ppa:transmissionbt/ppa

## Install some packages

sudo apt update
sudo apt --yes full-upgrade
echo sudo apt --yes install "${UBUNTU_APPS[*]}"
sudo apt --yes install ${UBUNTU_APPS[*]}
echo sudo apt --yes build-dep "${UBUNTU_BUILD_DEPS[*]}"
sudo apt --yes build-dep ${UBUNTU_BUILD_DEPS[*]}
sudo apt --yes autoremove
sudo apt-get clean

