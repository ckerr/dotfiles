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

zshrc="${ZDOTDIR:-$HOME}/.zshrc"
rm -rf "${zshrc}"
zshdir="${ZSH:-${HOME}/.oh-my-zsh}"
rm -rf "${zshdir}"
zshcustom="${ZSH_CUSTOM:-${zshdir}/custom/}"
rm -rf "${zshcustom}"

## Install new versions

name="oh-my-zsh"
get_repo "${name}" "https://github.com/robbyrussell/${name}.git" "${zshdir}"
name="zsh-nvm"
get_repo "${name}" "https://github.com/lukechilds/${name}" "${zshcustom}/plugins/${name}"
name="zsh-autosuggestions"
get_repo "${name}" "https://github.com/zsh-users/${name}" "${zshcustom}/plugins/${name}"
name="zsh-fzy"
get_repo "${name}" "https://github.com/aperezdc/${name}" "${zshcustom}/plugins/${name}"
name="powerlevel9k"
get_repo "${name}" "https://github.com/bhilburn/${name}" "${zshcustom}/themes/${name}"

## install dotfiles

(cd assets/public/dotfiles \
  && find -name ".[^.]*"    -type f -exec install -v -Dm 644 "{}" "${ZDOTDIR:-$HOME}/{}" \; \
  && find -path ".[^.]*/**" -type f -exec install -v -Dm 644 "{}" "${ZDOTDIR:-$HOME}/{}" \;)

(cd assets/private/dotfiles \
  && find -name ".[^.]*"    -type f -exec install -v -Dm 600 "{}" "${ZDOTDIR:-$HOME}/{}" \; \
  && find -path ".[^.]*/**" -type f -exec install -v -Dm 600 "{}" "${ZDOTDIR:-$HOME}/{}" \;)

echo $0 done
