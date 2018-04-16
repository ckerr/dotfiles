#!/usr/bin/env bash

COLORSCHEME=afterglow

##
##

. ./common.sh

viminit="${VIMINIT:-${HOME}/.vimrc}"
vimruntime="${VIMRUNTIME:-${HOME}/.vim}"

##
# install colorschemes
tmpdir=$(mktemp -d -t 'setup-vim.XXXXXXXX')
trap "{ rm -rf "${tmpdir}"; }" EXIT
color_staging_dir="${tmpdir}/colorschemes"
get_repo "awesome-vim-colorschemes" \
         "https://github.com/rafi/awesome-vim-colorschemes.git" \
         "${color_staging_dir}"
cp -R "${color_staging_dir}/colors" "${vimruntime}"

##
# set variables
touch "${viminit}"
set_variable_in_file "${viminit}" ":set\ shiftwidth=" ":set shiftwidth=2"
set_variable_in_file "${viminit}" ":set\ expandtab" ":set expandtab"
set_variable_in_file "${viminit}" ":syntax" ":syntax on"
set_variable_in_file "${viminit}" ":colorscheme\ " ":colorscheme ${COLORSCHEME}"
