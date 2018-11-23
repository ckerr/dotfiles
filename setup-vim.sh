#!/usr/bin/env bash

. ./common.sh
vimruntime="${VIMRUNTIME:-${HOME}/.vim}"
vimplugindir="${vimruntime}/pack/plugins/start"

mkdir -vp "${vimplugindir}"

name="awesome-vim-colorschemes"
get_repo "${name}" "https://github.com/rafi/${name}.git" "${vimplugindir}/${name}"

name="vim-cpp-enhanced-highlight"
get_repo "${name}" "https://github.com/octol/${name}.git" "${vimplugindir}/${name}"

name="vim-javascript"
get_repo "${name}" "https://github.com/pangloss/${name}.git" "${vimplugindir}/${name}"

name="YouCompleteMe"
get_repo "${name}" "https://github.com/Valloric/${name}.git" "${vimplugindir}/${name}"
pushd "${vimplugindir}/${name}"
git submodule update --init --recursive
./install.py
popd

echo $0 done
