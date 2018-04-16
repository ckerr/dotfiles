#!/usr/bin/env bash

if [ "" != "$(command -v gsed)" ]; then
  sedcmd=gsed
else
  sedcmd=sed
fi

###
###  Helpers
###

# Modify variables in a file.
# Doesn't assume much since syntaxes vary e.g. between .zshrc and .vimrc
function set_variable_in_file {
  filename=$1
  search=$2
  var=$3

  # if there's a line starting with $search, replace it
  count=$(grep --count "^${search}" "${filename}")
  if [ "${count}" -eq "1" ]; then
    ${sedcmd} --in-place='' "s/^${search}.*/${var}/" "${filename}"
    return
  fi

  # if there's a line starting with "# $search", insert our version there
  if [ "$(grep --count "^# ${search}" "${filename}")" -eq "1" ]; then
    ${sedcmd} --in-place='' "/^# ${key}.*/a \\${var}" "${filename}"
    return
  fi

  # not found at all; just add it to the end
  echo "${var}" >> "${filename}"
}

function set_variable_in_shell_script {
  filename=$1
  key=$2
  val=$3

  set_variable_in_file "${filename}" "${key}=" "${key}=\"${val}\""
}

function get_repo {
  name=$1
  repo_url=$2
  destination=$3

  if [ -d "${destination}" ]; then
    echo "updating ${name}"
    pushd "${destination}"
    git pull
    popd
  else
    # ensure the parent directory exists
    parent=$(dirname "${destination}")
    if [ ! -d "${parent}" ]; then
      mkdir -p "${parent}"
      chmod 750 "${parent}"
    fi

    echo "installing ${name}"
    env git clone -q --depth=1 "${repo_url}" "${destination}"
    chmod 750 "${destination}"
  fi
}

