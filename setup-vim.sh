#!/usr/bin/env bash

COLORSCHEME=afterglow


# Prerequisites

. ./common.sh

viminit="${VIMINIT:-${HOME}/.vimrc}"
vimplugindir="${VIMRUNTIME:-${HOME}/.vim}/pack/plugins/start"


# Update plugins

mkdir -vp "${vimplugindir}"

name="awesome-vim-colorschemes"
get_repo "${name}" "https://github.com/rafi/${name}.git" "${vimplugindir}/${name}"

name="vim-cpp-enhanced-highlight"
get_repo "${name}" "https://github.com/octol/${name}.git" "${vimplugindir}/${name}"


# Initialize .vimrc

touch "${viminit}"
set_variable_in_file "${viminit}" ":set\ shiftwidth=" ":set shiftwidth=2"
set_variable_in_file "${viminit}" ":set\ expandtab" ":set expandtab"
set_variable_in_file "${viminit}" ":syntax" ":syntax on"
set_variable_in_file "${viminit}" ":colorscheme\ " ":colorscheme ${COLORSCHEME}"
