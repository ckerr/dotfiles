#!/usr/bin/env bash

. ./common.sh
declare -r vimruntime="${VIMRUNTIME:-${HOME}/.vim}"
declare -r vimplugindir="${vimruntime}/pack/plugins/start"

"${gmkdir}" -vp "${vimplugindir}"

get_repo "${vimplugindir}" 'https://github.com/rafi/awesome-vim-colorschemes.git'
get_repo "${vimplugindir}" 'https://github.com/leafgarland/typescript-vim.git'
get_repo "${vimplugindir}" 'https://github.com/octol/vim-cpp-enhanced-highlight.git'
get_repo "${vimplugindir}" 'https://github.com/pangloss/vim-javascript.git'
get_repo "${vimplugindir}" 'https://github.com/tpope/vim-sleuth.git'

declare path="${vimplugindir}/YouCompleteMe"
declare repo_url='https://github.com/Valloric/YouCompleteMe.git'
if ! is_repo_current "${path}" "${repo_url}"; then
  get_repo "${vimplugindir}" "${repo_url}"
  (cd "${path}" && ./install.py)
fi

echo $0 done
