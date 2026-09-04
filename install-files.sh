#!/usr/bin/env bash

set -uo pipefail

. ./common.sh

# `install` defaults to mode 0755, which is wrong for config files --
# and dangerous for anything holding a token -- so set the mode explicitly.
declare -r file_mode=0644
declare -r exec_mode=0755

# Both globs are needed and they do not overlap: `-name` catches dotfiles
# at the top level (.gitconfig), `-path` catches files nested inside a
# dot-directory (.zshrc.d/git.zsh, .config/mpv/mpv.conf).
function install_tree {
  local -r src="${1}"
  local -r dest="${2}"
  local -r mode="${3}"

  if [ ! -d "${src}" ]; then
    echo "skipping ${src}: not present"
    return 0
  fi

  ( cd "${src}" \
    && $gfind -name ".[^.]*"    -type f -exec $ginstall -D -m "${mode}" "{}" "${dest}/{}" \; -print \
    && $gfind -path ".[^.]*/**" -type f -exec $ginstall -D -m "${mode}" "{}" "${dest}/{}" \; -print )
}

install_tree assets/public/dotfiles "${HOME}" "${file_mode}"
install_tree assets/public/scripts  "${HOME}" "${exec_mode}"

# ~/.lessfilter is invoked by lesspipe and has to be executable.
if [ -f "${HOME}/.lessfilter" ]; then
  chmod "${exec_mode}" "${HOME}/.lessfilter"
fi

echo "$0 done"
