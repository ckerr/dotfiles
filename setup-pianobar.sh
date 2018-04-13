#!/usr/bin/env bash

. ./assets/env.sh

pkg_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/pianobar"
pkg_config_file="${pkg_config_dir}/config"
tmp_file="${pkg_config_dir}/tmp.txt"

mkdir -p "${pkg_config_dir}"
chmod 750 "${pkg_config_dir}"
echo "enter master password:"
touch "${tmp_file}"
trap "rm -f '${tmp_file}'" EXIT
chmod 600 "${tmp_file}"
kpcli --readonly --kdb="${HOME}/passwords/passwords.kdbx" --command="show -f passwords/Recreational/pandora.com" >> "${tmp_file}"
user=$(grep "Uname:" "${tmp_file}" | cut -d: -f2 | tr -d "[:blank:]")
pass=$(grep "Pass:" "${tmp_file}" | cut -d: -f2 | tr -d "[:blank:]")

touch "${pkg_config_file}"
chmod 600 "${pkg_config_file}"
echo "volume = -2" > "${pkg_config_file}"
echo "user = ${user}" >> "${pkg_config_file}"
echo "password = ${pass}" >> "${pkg_config_file}"

rm "${tmp_file}"


