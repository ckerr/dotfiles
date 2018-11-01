#!/usr/bin/env bash

. ./common.sh

vimplugindir="${VIMRUNTIME:-${HOME}/.vim}/pack/plugins/start"

mkdir -vp "${vimplugindir}"

name="awesome-vim-colorschemes"
get_repo "${name}" "https://github.com/rafi/${name}.git" "${vimplugindir}/${name}"

name="vim-cpp-enhanced-highlight"
get_repo "${name}" "https://github.com/octol/${name}.git" "${vimplugindir}/${name}"

name="vim-javascript"
get_repo "${name}" "https://github.com/pangloss/${name}.git" "${vimplugindir}/${name}"

echo $0 done
