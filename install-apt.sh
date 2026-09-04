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
  glow # markdown renderer used by ~/.lessfilter
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
  mediainfo
  meld
  mpv
  ncdu
  ninja-build
  openssl
  optipng
  opus-tools
  pandoc
  plocate
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
  local -r key_url="${1}"
  local -r repo_url="${2}"
  local -r name="${3}"
  local -r suite="${4-stable}"
  local -r component="${5-main}"

  local -r keyring="/etc/apt/keyrings/${name}.gpg"
  local -r sources_file="/etc/apt/sources.list.d/${name}.sources"
  local -r legacy_list="/etc/apt/sources.list.d/${name}.list"
  local -r arch="$(dpkg --print-architecture)"

  echo "adding apt repo ${name}"

  # Fetch to a temp file first: this pipeline's exit status would
  # otherwise be tee's, and a failed download would go unnoticed.
  local -r tmpkey="$(mktemp)"
  if ! wget --quiet --output-document="${tmpkey}" "${key_url}"; then
    echo "warning: could not fetch signing key for ${name}; skipping repo" >&2
    rm --force "${tmpkey}"
    return 0
  fi

  sudo install --directory --mode=0755 /etc/apt/keyrings
  gpg --dearmor < "${tmpkey}" | sudo tee "${keyring}" > /dev/null
  rm --force "${tmpkey}"
  sudo chmod 0644 "${keyring}"

  printf 'Types: deb\nURIs: %s\nSuites: %s\nComponents: %s\nArchitectures: %s\nSigned-By: %s\n' \
    "${repo_url}" "${suite}" "${component}" "${arch}" "${keyring}" \
    | sudo tee "${sources_file}" > /dev/null

  # Drop the .list this script wrote before it emitted deb822, so apt
  # does not end up with the same repo defined twice.
  if [ -f "${legacy_list}" ]; then
    echo "removing superseded ${legacy_list}"
    sudo rm --force "${legacy_list}"
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
         'google-chrome' \
         'stable' 'main'

# source: https://github.com/microsoft/vscode/issues/2973#issuecomment-280575841
add_repo 'https://packages.microsoft.com/keys/microsoft.asc' \
         'https://packages.microsoft.com/repos/vscode' \
         'vscode' \
         'stable' 'main'

# source: https://www.ubuntuupdates.org/ppa/virtualbox.org_contrib
add_repo 'http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc' \
         'http://download.virtualbox.org/virtualbox/debian' \
         'virtualbox.org' \
         "$(lsb_release --short --codename)" "non-free contrib"

# source: https://apt.syncthing.net/
add_repo 'https://syncthing.net/release-key.txt' \
         'https://apt.syncthing.net/' \
         'syncthing' \
         'syncthing' 'stable-v2'

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

