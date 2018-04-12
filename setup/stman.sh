#/usr/bin/env bash

# create the config file that stman requires
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
pkg=syncthingmanager
pkg_config_dir=${config_dir}/${pkg}
rm ${pkg_config_dir}/${pkg}.conf
rmdir ${pkg_config_dir}
stman configure --port 8080
