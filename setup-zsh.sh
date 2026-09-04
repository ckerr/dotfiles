#!/usr/bin/env bash

. ./common.sh

# check for required tools
declare -r packages=( git chsh )
for var in "${packages[@]}"
do
  if ! [ -x "$(command -v ${var})" ]; then
    echo "Error: package ${var} is not installed." >&2
    exit 1
  fi
done

###
###  Set the shell
###

# set login shell to zsh
if [[ "$SHELL" != *zsh ]]; then
  echo 'changing login shell to zsh'
  chsh -s $(which zsh)
fi

# Install OMZ and plugins.
#
# get_repo rebases an existing checkout rather than replacing it, so
# there is no old version to clear out first.

declare -r zshdir="${ZSH:-${HOME}/.oh-my-zsh}"
declare -r zshcustom="${ZSH_CUSTOM:-${zshdir}/custom}"

get_repo "${HOME}" 'https://github.com/robbyrussell/oh-my-zsh.git' '.oh-my-zsh'
get_repo "${zshcustom}/plugins" 'https://github.com/aperezdc/zsh-fzy.git'
get_repo "${zshcustom}/plugins" 'https://github.com/lukechilds/zsh-nvm.git'
get_repo "${zshcustom}/plugins" 'https://github.com/zsh-users/zsh-autosuggestions.git'
get_repo "${zshcustom}/themes"  'https://github.com/romkatv/powerlevel10k.git'

echo $0 done
