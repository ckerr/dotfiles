#!/usr/bin/env bash

if [ 'x' != "x$(command -v gsed)" ]; then
  declare -r gsed='gsed'
else
  declare -r gsed='sed'
fi

if [ 'x' != "x$(command -v gfind)" ]; then
  declare -r gfind='gfind'
else
  declare -r gfind='find'
fi

if [ 'x' != "x$(command -v ginstall)" ]; then
  declare -r ginstall='ginstall'
else
  declare -r ginstall='install'
fi

###
###  Helpers
###

# https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
function is_repo_current() {
  local -r path="${1}"

  if [ ! -d "${path}/.git" ]; then
    return 1
  fi

  env git -C "${path}" remote update &> /dev/null || return 1

  local local_head remote_head
  local_head="$(env git -C "${path}" rev-parse @ 2>/dev/null)" || return 1
  # No upstream (e.g. a detached head) means there is nothing to compare
  # against, so treat the checkout as current rather than trying to pull.
  remote_head="$(env git -C "${path}" rev-parse '@{u}' 2>/dev/null)" || return 0

  [ "${local_head}" = "${remote_head}" ]
}

function get_repo() {
  local -r parent_dir="${1}"
  local -r repo_url="${2}"
  if (( $# > 2 )); then
    local -r name="${3}"
  else
    local tmp="${repo_url}"
    tmp="${tmp##*/}" # basename
    local -r name="${tmp%%.*}" # strip suffix
    unset tmp
  fi

  echo "getting ${repo_url}"

  local -r path="${parent_dir}/${name}"
  if is_repo_current "${path}"; then
    return 0
  fi

  if [ -d "${path}/.git" ]; then
    env git -C "${path}" pull --stat --rebase --prune
  else
    # ensure parent directory exists
    if [ ! -d "${parent_dir}" ]; then
      mkdir -p "${parent_dir}"
      chmod 750 "${parent_dir}"
    fi
    env git clone -q "${repo_url}" "${path}"
    chmod 750 "${path}"
  fi
  env git -C "${path}" submodule update --init --recursive
}
