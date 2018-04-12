#/usr/bin/env bash
. assets/env.sh

# create the config file so that stman can run
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
pkg=syncthingmanager
pkg_config_dir=${config_dir}/${pkg}
rm ${pkg_config_dir}/${pkg}.conf
rmdir ${pkg_config_dir}
stman configure --port 8080

# connect to the mothership
stman device add \
  --name "${STMAN_ADD_DEVICE_NAME}" \
  --address "${STMAN_ADD_DEVICE_ADDRESS}" \
  "${STMAN_ADD_DEVICE_ID}"
echo "please check ${STMAN_ADD_DEVICE_NAME} for a pair request"
