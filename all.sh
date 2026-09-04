#!/usr/bin/env bash
#
# Run every installer, in dependency order.

set -euo pipefail

# All the sub-scripts use paths relative to the repo root.
cd "$(dirname "${BASH_SOURCE[0]}")"

# Native packages first; everything below assumes git, zsh and vim exist.
./install-apt.sh
./install-brew.sh

# Deploy the dotfiles before setting zsh up, so that the .zshrc which
# setup-zsh.sh's oh-my-zsh install is meant to satisfy is already in place.
./install-files.sh

./setup-zsh.sh
./setup-vim.sh

# Must follow setup-zsh.sh: this shells out to an interactive zsh to let
# the zsh-nvm plugin bootstrap nvm before any npm package is installed.
./install-npm.sh

./install-pip.sh
./install-memories.sh

echo "$0 done"
