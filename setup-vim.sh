#!/usr/bin/env bash

. ./common.sh
declare -r vimruntime="${VIMRUNTIME:-${HOME}/.vim}"
declare -r vimplugindir="${vimruntime}/pack/plugins/start"

"${gmkdir}" -vp "${vimplugindir}"

# collection of awesome color schemes for Neo/vim, merged for quick use.
get_repo "${vimplugindir}" 'https://github.com/rafi/awesome-vim-colorschemes.git'

# a collection of language packs for Vim.
get_repo "${vimplugindir}" 'https://github.com/sheerun/vim-polyglot.git'

# automatically adjusts 'shiftwidth' and 'expandtab' based on the current file,
# or other files of the same type in the current and parent directories
get_repo "${vimplugindir}" 'https://github.com/tpope/vim-sleuth.git'

declare path="${vimplugindir}/YouCompleteMe"
declare repo_url='https://github.com/Valloric/YouCompleteMe.git'
if ! is_repo_current "${path}" "${repo_url}"; then
  get_repo "${vimplugindir}" "${repo_url}"
  (cd "${path}" && ./install.py)
fi

echo $0 done
