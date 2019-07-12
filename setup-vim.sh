#!/usr/bin/env bash

. ./common.sh
declare -r vimruntime="${VIMRUNTIME:-${HOME}/.vim}"
declare -r vimplugindir="${vimruntime}/pack/plugins/start"

"${gmkdir}" -vp "${vimplugindir}"

user='rafi'
name='awesome-vim-colorschemes'
get_repo "${name}" "https://github.com/${user}/${name}.git" "${vimplugindir}/${name}"

user='octol'
name='vim-cpp-enhanced-highlight'
get_repo "${name}" "https://github.com/${user}/${name}.git" "${vimplugindir}/${name}"

user='pangloss'
name='vim-javascript'
get_repo "${name}" "https://github.com/${user}/${name}.git" "${vimplugindir}/${name}"

user='leafgarland'
name='typescript-vim'
get_repo "${name}" "https://github.com/${user}/${name}.git" "${vimplugindir}/${name}"

user='Valloric'
name='YouCompleteMe'
get_repo "${name}" "https://github.com/${user}/${name}.git" "${vimplugindir}/${name}"
pushd "${vimplugindir}/${name}"
git submodule update --init --recursive
./install.py
popd

echo $0 done
