#!/usr/bin/env zsh

NODE_PACKAGES=(
  asar
  dev-time-cli
  empty-trash-cli
  fkill-cli
  gh-home
  http-echo-server
  json
  npmrc
  vmd
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

# install node
zsh -ic "echo this interactive shell nudges zsh-nvm to bootstrap nvm"
source ${NVM_DIR:~/.nvm}/nvm.sh
nvm install node # 'node' is an alias for the latest version

# install node packages
npm --global update
for item in "${NODE_PACKAGES[@]}"
do
  npm_install $item
done
npm --global cache verify


