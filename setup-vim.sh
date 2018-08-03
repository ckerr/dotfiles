#!/usr/bin/env bash

COLORSCHEME=afterglow

##
##

. ./common.sh

viminit="${VIMINIT:-${HOME}/.vimrc}"
vimruntime="${VIMRUNTIME:-${HOME}/.vim}"

tmpdir=$(mktemp -d -t "setup-vim.XXXXXXXX")
trap "{ rm -rf "${tmpdir}"; }" EXIT

##
# install colorschemes
name="awesome-vim-colorschemes"
staging_dir="${tmpdir}/${name}"
get_repo "${name}" "https://github.com/rafi/${name}.git" "${staging_dir}"
cp -R -v "${staging_dir}/colors" "${vimruntime}"

##
# install improved C++ syntax highlighting
name="vim-cpp-enhanced-highlight"
staging_dir="${tmpdir}/${name}"
get_repo "${name}" "https://github.com/octol/${name}.git" "${staging_dir}"
cp -R -v "${staging_dir}/after" "${vimruntime}"

##
# set some vim variables
touch "${viminit}"
set_variable_in_file "${viminit}" ":set\ shiftwidth=" ":set shiftwidth=2"
set_variable_in_file "${viminit}" ":set\ expandtab" ":set expandtab"
set_variable_in_file "${viminit}" ":syntax" ":syntax on"
set_variable_in_file "${viminit}" ":colorscheme\ " ":colorscheme ${COLORSCHEME}"
