#!/usr/bin/env bash

COLORSCHEME=PaperColor

##
##

. ./common.sh

viminit="${VIMINIT:-${HOME}/.vimrc}"
vimruntime="${VIMRUNTIME:-${HOME}/.vim}"

##
# install colorschemes
tmpdir=$(mktemp -d -t 'setup-vim.XXXXXXXX')
trap "{ rm -rf $tmpdir; }" EXIT
color_staging_dir="${tmpdir}/colorschemes"
get_repo "awesome-vim-colorschemes" \
         "https://github.com/rafi/awesome-vim-colorschemes.git" \
         "${color_staging_dir}"
cp -R "${color_staging_dir}/colors" "${vimruntime}"

##
# set colorscheme
touch "${viminit}"
needle="^colorscheme"
cmd="colorscheme ${COLORSCHEME}"
grep --files-with-matches "${needle}" "${viminit}"
if [[ $? == 0 ]]; then
  sed --in-place='' "s/${needle}.*/${cmd}/" "${viminit}"
else
  echo "${cmd}" >> "${viminit}"
fi
