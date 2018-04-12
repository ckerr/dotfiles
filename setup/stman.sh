#/usr/bin/env bash

pkg=syncthingmanager
pkg_config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/${pkg}

# create the config file that stman requires
rm ${pkg_config_dir}/${pkg}.conf 2>/dev/null
rmdir ${pkg_config_dir} 2>/dev/null
stman configure --port 8080
chmod 770 ${pkg_config_dir}
chmod 600 ${pkg_config_dir}/${pkg}.conf
