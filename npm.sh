#!/usr/bin/env bash

NODE_PACKAGES=(
  dev-time-cli
)
#npm_install http-server
#npm_install empty-trash-cli
#npm_install fkill-cli
#npm_install speed-test
#npm_install gh-home
#require_npm pretty-error

##
##

function npm_install() {
  echo "npm $*"
  item=$1

  npm list --global --parseable ${item}
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


