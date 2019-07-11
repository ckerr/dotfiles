#!/usr/bin/env bash

. ./common.sh

# check for required tools
packages=( git chsh )
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
  echo "changing login shell to zsh"
  chsh -s $(which zsh)
fi

# Install OMZ and plugins

## Remove the old versions

zshdir="${ZSH:-${HOME}/.oh-my-zsh}"
zshcustom="${ZSH_CUSTOM:-${zshdir}/custom/}"

## Install new versions

user='robbyrussell'
name='oh-my-zsh'
get_repo "${name}" "https://github.com/${user}/${name}.git" "${zshdir}"

user='lukechilds'
name='zsh-nvm'
get_repo "${name}" "https://github.com/${user}/${name}" "${zshcustom}/plugins/${name}"

user='zsh-users'
name='zsh-autosuggestions'
get_repo "${name}" "https://github.com/${user}/${name}" "${zshcustom}/plugins/${name}"

user='aperezdc'
name='zsh-fzy'
get_repo "${name}" "https://github.com/${user}/${name}" "${zshcustom}/plugins/${name}"

user='bhilburn'
name='powerlevel9k'
get_repo "${name}" "https://github.com/${user}/${name}" "${zshcustom}/themes/${name}"

echo $0 done
