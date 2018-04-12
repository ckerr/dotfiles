#!/usr/bin/env bash

SNAP_APPS=(
  cppcheck
  gitkraken
  htop
  keepassxc
  rg
)

##
##

# only run this on systems that have snappy
if [ "" == $(command -v snap) ]; then
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

function snap_install()
{
  item=$1

  snap list ${item} > /dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo "already installed: ${item}"
  else
    sudo snap install --stable "${item}"
    exit_if_error "${item}"
  fi
}

##
##

# update snaps
echo "updating snaps"
sudo snap refresh

# install snaps
for item in "${SNAP_APPS[@]}"
do
  snap_install $item
done

