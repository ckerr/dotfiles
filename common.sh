#!/usr/bin/env bash

###
###  Helpers
###

# modify variables in a script file
# looks for lines beginning with "KEY=" or "# KEY="
# and inserts there
function set_variable_in_file {
  filename=$1
  key=$2
  val=$3

  # if there's a line starting with "KEY=", replace it
  if [ "$(grep --count "^$key=" "$filename")" -eq "1" ]; then
    ${sedcmd} --in-place='' "s/^${key}=.*/${key}=\"${val}\"/" "${filename}"
    return
  fi

  # if there's a line starting with "# KEY=", add our keyval there
  if [ "$(grep --count "^# $key=" "$filename")" -eq "1" ]; then
    ${sedcmd} --in-place='' "/^# ${key}=.*/a \\${key}=\"${val}\"" "${filename}"
    return
  fi

  echo not found in $filename: $key
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

