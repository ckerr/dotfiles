#!/usr/bin/env bash

# cpplint

UBUNTU_APPS=(
  ddclient
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

## Install some packages

sudo apt update
sudo apt --yes full-upgrade
for item in "${UBUNTU_APPS[@]}"
do
  apt_install $item
done
sudo apt autoremove
sudo apt-get clean

staging_dir=${PWD}/assets/zsh-custom
sudo install -m 0600 -o root "${staging_dir}/ddclient.conf" "/etc"

install
sudo cp assets/

# https://askubuntu.com/questions/940283/run-ddclient-as-a-service-in-16-04
sudo update-rc.d ddclient enable
