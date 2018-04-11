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
  if [ "$(grep --count "^$key=" "$filename")" -eq "1" ]; then
    $sedcmd --in-place='' "s/^$key=.*/$key=\"$val\"/" "${filename}"
    return
  fi
  if [ "$(grep --count "^# $key=" "$filename")" -eq "1" ]; then
    $sedcmd --in-place='' "/^# $key=.*/a \\$key=\"$val\"" "${filename}"
    return
  fi
  echo not found in $filename: $key
}


###
###  ZSH
###

# set login shell to zsh
user=$(whoami)
shell_path=$(getent passwd | grep "${user}" | cut -d: -f7)
shell_name=$(basename "${shell_path}")
if [ "x$shell_name" != "xzsh" ]; then
  echo "changing login shell to zsh"
  chsh -s $(which zsh)
fi
zshrc="${ZDOTDIR:-$HOME}/.zshrc"

# install oh-my-zsh
zshdir="${ZSH:-${HOME}/.oh-my-zsh}"
zshcustom="${ZSH_CUSTOM:-${zshdir}/custom/}"
addme_name="oh-my-zsh"
addme_dir="${zshdir}"
addme_url="https://github.com/robbyrussell/${addme_name}.git"
if [ ! -d ${addme_dir} ]; then
  echo "installing ${addme_name}"
  env git clone -q --depth=1 "${addme_url}" "${addme_dir}"
  cp "${addme_dir}/templates/zshrc.zsh-template" "${zshrc}"
fi

# install zsh-autosuggestions
addme_name="zsh-autosuggestions"
addme_dir="${zshcustom}/plugins/${addme_name}"
addme_url="https://github.com/zsh-users/${addme_name}"
if [ ! -d "${addme_dir}" ]; then
  echo "installing ${addme_name}"
  env git clone -q --depth=1 "${addme_url}" "${addme_dir}"
  cp ./zsh-custom/${addme_name}.custom.zsh "${zshcustom}"
  $sedcmd --in-place='' "/^plugins=(/a \  ${addme_name}" "${zshrc}"
fi 

# install powerlevel9k
addme_name="powerlevel9k"
addme_dir="${zshcustom}/themes/${addme_name}"
addme_url="https://github.com/bhilburn/${addme_name}.git"
if [ ! -d ${addme_dir} ]; then
  echo "installing ${addme_name}"
  env git clone -q --depth=1 "${addme_url}" "${addme_dir}"
  cp ./zsh-custom/${addme_name}.custom.zsh "${zshcustom}"
  set_variable_in_file "$zshrc" "ZSH_THEME" "${addme_name}\/${addme_name}"
fi 

# install history preferences
addme_file="history.zsh"
if [ ! -f "${zshcustom}/${addme_file}" ]; then
  echo "installing ${addme_file}"
  cp ./zsh-custom/${addme_file} "${zshcustom}"
fi

# populate oh-my-zshrc plugins
addme_plugins=( nvm )
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
