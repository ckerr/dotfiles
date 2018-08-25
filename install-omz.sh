#!/usr/bin/env bash

. ./common.sh

# check for required tools
packages=( git grep chsh )
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

function add_custom_plugin_from_repo {
  name=$1
  repo_url=$2

  destination="${zshcustom}/plugins/$name"
  if [ ! -d "$destination" ]; then
    get_repo "${name}" "${repo_url}" "${destination}"
  fi
}


###
###  ZSH
###

# set login shell to zsh
if [[ "$SHELL" != *zsh ]]; then
  echo "changing login shell to zsh"
  chsh -s $(which zsh)
fi

# remove old files
rm -rvf "${zshrc}"
rm -rvf "${zshdir}"

# install omz
addme_name="oh-my-zsh"
addme_dir="${zshdir}"
get_repo "${addme_name}" \
         "https://github.com/robbyrussell/${addme_name}.git" \
         "${addme_dir}"

# install custom plugin: zsh-nvm
add_custom_plugin_from_repo "zsh-nvm" \
                            "https://github.com/lukechilds/zsh-nvm"

# install custom plugin: zsh-autosuggestions
name="zsh-autosuggestions"
add_custom_plugin_from_repo "${name}" "https://github.com/zsh-users/${name}"

# install custom plugin: zsh-fzy
name="zsh-fzy"
add_custom_plugin_from_repo "${name}" "https://github.com/aperezdc/${name}"

# install powerlevel9k
name="powerlevel9k"
get_repo "${name}" \
         "https://github.com/bhilburn/${name}.git" \
         "${zshcustom}/themes/${name}"


# install dotfiles
(cd assets/public/dotfiles  && find -name ".[^.]*"      -type f -exec install -v -Dm 644 "{}" "${ZDOTDIR:-$HOME}/{}" \;)
(cd assets/public/dotfiles  && find -path ".[^.]*/**/*" -type f -exec install -v -Dm 644 "{}" "${ZDOTDIR:-$HOME}/{}" \;)
(cd assets/private/dotfiles && find -name ".[^.]*"      -type f -exec install -v -Dm 600 "{}" "${ZDOTDIR:-$HOME}/{}" \;)
(cd assets/private/dotfiles && find -path ".[^.]*/**/*" -type f -exec install -v -Dm 600 "{}" "${ZDOTDIR:-$HOME}/{}" \;)

echo $0 done
