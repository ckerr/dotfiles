#/usr/bin/env bash

config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
package=syncthingmanager
package_config_dir=${config_dir}/${package}
rm ${pkg_config_dir}/${package}.conf
rmdir ${pkg_config_dir}

stman configure --port 8080
