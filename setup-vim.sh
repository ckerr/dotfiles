#!/usr/bin/env bash

set -uo pipefail

. ./common.sh

# Not ${VIMRUNTIME}: that is vim's own variable for its *system* runtime
# (/usr/share/vim/vim91), so honouring it here would scatter personal
# plugins across a root-owned directory. The user runtime is ~/.vim.
declare -r vimdir="${HOME}/.vim"
declare -r vimplugindir="${vimdir}/pack/plugins/start"
declare -r vimcolorsdir="${vimdir}/colors"
declare -r vimextrasdir="${vimdir}/extras"
declare -r vimsyntaxdir="${vimdir}/syntax"

mkdir -vp "${vimcolorsdir}"
mkdir -vp "${vimextrasdir}"
mkdir -vp "${vimplugindir}"
mkdir -vp "${vimsyntaxdir}"

# collection of awesome color schemes for Neo/vim, merged for quick use.
# get_repo "${vimplugindir}" 'https://github.com/rafi/awesome-vim-colorschemes.git'

# vibrant ink -like colorscheme
get_repo "${vimextrasdir}" 'https://github.com/tpope/vim-vividchalk.git'
# -f so re-running the script does not fail on an existing symlink
ln -sf "${vimextrasdir}/vim-vividchalk/colors/vividchalk.vim" "${vimcolorsdir}/"

# A Vim text editor plugin to swap delimited items.
get_repo "${vimplugindir}" 'https://github.com/machakann/vim-swap.git'

# filesystem navigation / management
get_repo "${vimplugindir}" 'https://github.com/preservim/nerdtree.git'

# a collection of language packs for Vim.
get_repo "${vimplugindir}" 'https://github.com/sheerun/vim-polyglot.git'

# automatically adjusts 'shiftwidth' and 'expandtab' based on the current file,
# or other files of the same type in the current and parent directories
get_repo "${vimplugindir}" 'https://github.com/tpope/vim-sleuth.git'

# easily search for, substitute, and abbreviate multiple variants of a word
get_repo "${vimplugindir}" 'https://github.com/tpope/vim-abolish.git'

# Surround.vim is all about "surroundings": parentheses, brackets, quotes,
# XML tags, and more. The plugin provides mappings to easily delete, change
# and add such surroundings in pairs.
get_repo "${vimplugindir}" 'https://github.com/tpope/vim-surround.git'

# check syntax in Vim asynchronously and fix files, with Language Server Protocol (LSP) support
get_repo "${vimplugindir}" 'https://github.com/w0rp/ale.git'

# GN syntax highlighting
get_repo "${vimplugindir}" 'https://github.com/ngg/vim-gn.git'

# required by vim-shell
get_repo "${vimplugindir}" 'https://github.com/xolox/vim-misc'
# :fullscreen mode
get_repo "${vimplugindir}" 'https://github.com/xolox/vim-shell'

# Set of operators and textobjects to search/select/edit sandwiched texts.
get_repo "${vimplugindir}" 'https://github.com/machakann/vim-sandwich.git'

# a code-completion engine for Vim
#declare path="${vimplugindir}/YouCompleteMe"
#declare repo_url='https://github.com/Valloric/YouCompleteMe.git'
#if ! is_repo_current "${path}" "${repo_url}"; then
#  get_repo "${vimplugindir}" "${repo_url}"
#  (cd "${path}" && ./install.py)
#fi

echo "$0 done"
