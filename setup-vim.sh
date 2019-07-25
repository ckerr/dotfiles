#!/usr/bin/env bash

. ./common.sh
declare -r vimruntime="${VIMRUNTIME:-${HOME}/.vim}"
declare -r vimplugindir="${vimruntime}/pack/plugins/start"

"${gmkdir}" -vp "${vimplugindir}"

get_repo "${vimplugindir}" 'https://github.com/rafi/awesome-vim-colorschemes.git'
get_repo "${vimplugindir}" 'https://github.com/leafgarland/typescript-vim.git'
get_repo "${vimplugindir}" 'https://github.com/octol/vim-cpp-enhanced-highlight.git'
get_repo "${vimplugindir}" 'https://github.com/pangloss/vim-javascript.git'

get_repo "${vimplugindir}" 'https://github.com/Valloric/YouCompleteMe.git'
(cd "${vimplugindir}/YouCompleteMe" && ./install.py)

echo $0 done
