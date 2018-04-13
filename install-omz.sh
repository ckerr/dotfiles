#!/usr/bin/env bash

if [ "" != "$(command -v gsed)" ]; then
  sedcmd=gsed
else
  sedcmd=sed
fi

# check for required tools
packages=( git grep sed chsh )
if [ "Darwin" == "$(uname -s)" ]; then
  packages+=(gsed)
fi
for var in "${packages[@]}"
do
  if ! [ -x "$(command -v ${var})" ]; then
    echo "Error: package ${var} is not installed." >&2
    exit 1
  fi
done

zshdir="${ZSH:-${HOME}/.oh-my-zsh}"
zshcustom="${ZSH_CUSTOM:-${zshdir}/custom/}"
zshrc="${ZDOTDIR:-$HOME}/.zshrc"


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

function add_to_omz_plugin_list {
  name=$1

  $sedcmd --in-place='' "/^plugins=(/a \  ${name}" "${zshrc}"
}

function add_custom_plugin_from_repo {
  name=$1
  repo_url=$2

  destination="$zshcustom/plugins/$name"
  if [ ! -d "$destination" ]; then
    get_repo "${name}" "${repo_url}" "${destination}"
    add_to_omz_plugin_list "${name}"
  fi
}


###
###  ZSH
###

staging_dir=${PWD}/assets/zsh-custom

# set login shell to zsh
if [[ "$SHELL" != *zsh ]]; then
  echo "changing login shell to zsh"
  chsh -s $(which zsh)
fi

# install omz
addme_name="oh-my-zsh"
addme_dir="${zshdir}"
get_repo "${addme_name}" \
         "https://github.com/robbyrussell/${addme_name}.git" \
         "${addme_dir}"
cp -f "${addme_dir}/templates/zshrc.zsh-template" "${zshrc}"
chmod 640 "${zshrc}"

# install custom plugin: zsh-nvm
add_custom_plugin_from_repo "zsh-nvm" \
                            "https://github.com/lukechilds/zsh-nvm"

# install custom plugin: zsh-autosuggestions
name="zsh-autosuggestions"
add_custom_plugin_from_repo "zsh-autosuggestions" \
                            "https://github.com/zsh-users/${name}"
install -m 0640 "${staging_dir}/${name}.custom.zsh" "${zshcustom}"

# install powerlevel9k
name="powerlevel9k"
get_repo "${name}" \
         "https://github.com/bhilburn/${name}.git" \
         "${zshcustom}/themes/${name}"
install -m 0640 "${staging_dir}/${name}.custom.zsh" "${zshcustom}"
set_variable_in_file "${zshrc}" "ZSH_THEME" "${name}\/${name}"

# install other zsh custom
addme_file="other.zsh"
if [ ! -f "${zshcustom}/${addme_file}" ]; then
  echo "installing ${addme_file}"
  install -m 0640 "${staging_dir}/${addme_file}" "${zshcustom}"
fi

# select supported omz plugins
addme_plugins=( )
for addme_name in "${addme_plugins[@]}"
do
  if [ "0" -eq $(grep --count "${addme_name}" "${zshrc}") ]; then
    echo "adding ${addme_name} to oh-my-zsh plugin list"
    $sedcmd --in-place='' "/^plugins=(/a \  ${addme_name}" "${zshrc}"
  fi
done

set_variable_in_file "$zshrc" "HIST_STAMPS" "yyyy-mm-dd"
set_variable_in_file "$zshrc" "HYPHEN_INSENSITIVE" "true"
echo $0 done
