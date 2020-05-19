#!/usr/bin/env zsh

declare -r NODE_PACKAGES=(
  asar
  cli-markdown
  dev-time-cli
  empty-trash-cli
  fkill-cli
  gh-home
  http-echo-server
  json
  npmrc
  vmd
  yaml-cli
  yarn
  ytdl
)
#npm_install http-server
#npm_install speed-test
#require_npm pretty-error

##
##

function npm_install() {
  local -r item="${1}"

  echo "npm ${item}"
  npm list --global --parseable ${item} > /dev/null 2>&1
  if [[ $? != 0 ]]; then
    echo "npm install -g $*"
    npm install -g $@
  fi
}

function nvm_uninstall_all_but_current() {
  local -r current="$(nvm current)"
  for dir in ${NVM_DIR:-${HOME}/.nvm}/versions/node/*; do
    local version=$(basename "${dir}");
    if [[ "$version" != "$current" ]]; then
      nvm uninstall "$version"
    fi
  done
}

# install node
zsh -ic 'echo this interactive shell nudges zsh-nvm to bootstrap nvm'
source "${NVM_DIR:-${HOME}/.nvm}"/nvm.sh
# 'node' is an alias for the current version
nvm install node
# always default to the latest available node version on a shell
nvm alias default node
# trash the older versions
nvm_uninstall_all_but_current

# install node packages
npm --global update
for item in "${NODE_PACKAGES[@]}"
do
  npm_install $item
done
npm --global cache verify

# misc cleanup
nvm cache clear
