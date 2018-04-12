#!/usr/bin/env bash

PIP3_PACKAGES=(
  cclint
  cpplint
)

##
##

function pip3_install() {
  item=$1

  echo "pip3 $item"
  pip3 show "${item}" > /dev/null 2>&1
  if [[ $? != 0 ]]; then
    echo "pip3 install ${item}"
    pip3 install ${item}
  fi
}

# update locally-installed packages
# https://stackoverflow.com/questions/2720014/upgrading-all-packages-with-pip
pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U

for item in "${PIP3_PACKAGES[@]}"
do
  pip3_install $item
done


