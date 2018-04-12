#!/usr/bin/env bash

NODE_PACKAGES=(
  dev-time-cli
  empty-trash-cli
  fkill-cli
  gh-home
)
#npm_install http-server
#npm_install speed-test
#require_npm pretty-error

##
##

function npm_install() {
  item=$1

  echo "npm $item"
  npm list --global --parseable ${item} > /dev/null 2>&1
  if [[ $? != 0 ]]; then
    echo "npm install -g $*"
    npm install -g $@
  fi
}

# do it
npm --global update
for item in "${NODE_PACKAGES[@]}"
do
  npm_install $item
done
npm --global cache verify


