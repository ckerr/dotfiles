#!/usr/bin/env bash

set -uo pipefail

# cpplint
# hotspot

declare -r UBUNTU_APPS=(
  a2ps
  advancecomp
  aptitude
  atomicparsley # used by yt-dlp in install-pip.sh
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
  fdupes
  flac
  flake8
  fonts-cantarell
  fonts-firacode
  fonts-inconsolata
  fonts-powerline
  fzy
  gir1.2-appindicator3-0.1 # required by syncthing-gtk for system tray
  git
  glow # markdown renderer used by ~/.lessfilter
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
  lsof # required by ~/.zshrc.d/openports.zsh
  mediainfo
  meld
  mpv
  ncdu
  ninja-build
  openssl
  optipng
  opus-tools
  pandoc
  pipx # used by install-pip.sh
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
  libqt5core5a-dbgsym
  libqt5dbus5-dbgsym
  libqt5gui5-dbgsym
  libqt5network5-dbgsym
  libqt5qml5-dbgsym
  libqt5widgets5-dbgsym
  libqwt-qt5-dev
  libssl-dev
  libtool
  qt5-gtk-platformtheme-dbgsym
  qt5-gtk2-platformtheme-dbgsym
  qt5-qmake
  qtbase5-dev # replaces qt5-default, dropped after Ubuntu 20.04
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

## Add some repos

# google-chrome-stable is not in the Ubuntu archive, so this repo is what
# bootstraps it. Once installed, the package rewrites this same
# google-chrome.sources itself; match the URI its postinst uses so our
# run and its run do not keep flipping the file between two spellings of
# the same repo.
add_repo 'https://dl-ssl.google.com/linux/linux_signing_key.pub' \
         'https://dl.google.com/linux/chrome-stable/deb/' \
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

# https://wiki.ubuntu.com/Debug%20Symbol%20Packages
function ensure_ddebs_source_exists {
  local -r sources_file='/etc/apt/sources.list.d/ddebs.sources'
  local -r legacy_list='/etc/apt/sources.list.d/ddebs.list'
  local -r keyring='/usr/share/keyrings/ubuntu-dbgsym-keyring.gpg'
  local -r codename="$(lsb_release --short --codename)"

  if [ ! -f "${keyring}" ]; then
    sudo apt-get --yes install ubuntu-dbgsym-keyring
  fi

  # The old .list and this .sources describe the same repo, so leaving
  # both in place makes apt report every target as configured twice --
  # roughly 150 warnings per update. A release upgrade migrating sources
  # to deb822 is one way to end up with the pair.
  if [ -f "${legacy_list}" ]; then
    echo "removing superseded ${legacy_list}"
    sudo rm --force "${legacy_list}"
  fi

  echo "updating ${sources_file}"
  printf 'Types: deb\nURIs: http://ddebs.ubuntu.com\nSuites: %s %s-updates\nComponents: main restricted universe multiverse\nSigned-By: %s\n' \
    "${codename}" "${codename}" "${keyring}" \
    | sudo tee "${sources_file}" > /dev/null
}
ensure_ddebs_source_exists

# One refresh, after every source above is in place: the availability
# probe below needs the third-party and ddebs indices to be present or
# it will write those packages off as unavailable.
sudo apt update

# disabling 2019-07-11 because Disco not supported yet
#sudo add-apt-repository --no-update --yes ppa:transmissionbt/ppa

## Install some packages

# `apt install` aborts the entire transaction if even one name is
# unknown, so split the list into what this release actually has and
# what it does not.
declare -a available=()
declare -a unavailable=()
for item in "${UBUNTU_APPS[@]}"; do
  if apt-cache policy "${item}" 2>/dev/null | grep --quiet '^  Candidate: [^(]'; then
    available+=("${item}")
  else
    unavailable+=("${item}")
  fi
done

if (( ${#unavailable[@]} > 0 )); then
  echo "not available on this release, skipping: ${unavailable[*]}" >&2
fi

sudo apt --yes full-upgrade
sudo apt --yes install "${available[@]}"

# build-dep needs deb-src entries, which are off by default on newer
# releases, so do not let a missing source list fail the whole run.
if ! sudo apt --yes build-dep "${UBUNTU_BUILD_DEPS[@]}"; then
  echo "warning: build-dep failed; enable deb-src entries to use it" >&2
fi

sudo apt --yes autoremove
sudo apt-get clean

echo "$0 done"

