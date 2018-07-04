#!/usr/bin/env bash

. ./common.sh

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

function add_to_omz_plugin_list {
  name=$1
  echo "adding ${name} to oh-my-zsh plugin list"
  $sedcmd --in-place='' "/^plugins=(/a \  ${name}" "${zshrc}"
}

function add_custom_plugin_from_repo {
  name=$1
  repo_url=$2

  destination="${zshcustom}/plugins/$name"
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
add_custom_plugin_from_repo "${name}" "https://github.com/zsh-users/${name}"
install -m 0640 "${staging_dir}/${name}.custom.zsh" "${zshcustom}"

# install custom plugin: zsh-fzy
name="zsh-fzy"
add_custom_plugin_from_repo "${name}" "https://github.com/aperezdc/${name}"
install -m 0640 "${staging_dir}/${name}.custom.zsh" "${zshcustom}"

# install powerlevel9k
name="powerlevel9k"
get_repo "${name}" \
         "https://github.com/bhilburn/${name}.git" \
         "${zshcustom}/themes/${name}"
install -m 0640 "${staging_dir}/${name}.custom.zsh" "${zshcustom}"
set_variable_in_shell_script "${zshrc}" "ZSH_THEME" "${name}\/${name}"


# install other zsh custom
addme_file="other.zsh"
if [ ! -f "${zshcustom}/${addme_file}" ]; then
  echo "installing ${addme_file}"
  install -m 0640 "${staging_dir}/${addme_file}" "${zshcustom}"
fi

# select supported omz plugins
addme_plugins=(
  command-not-found
  dircycle
)
for addme_name in "${addme_plugins[@]}"
do
  if [ "0" -eq $(grep --count "${addme_name}" "${zshrc}") ]; then
    add_to_omz_plugin_list "${addme_name}"
  fi
done

set_variable_in_shell_script "$zshrc" "HIST_STAMPS" "yyyy-mm-dd"
set_variable_in_shell_script "$zshrc" "HYPHEN_INSENSITIVE" "true"
echo $0 done
