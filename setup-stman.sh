#/usr/bin/env bash

. assets/private/stman-env.sh

# create the config file so that stman can run
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
pkg=syncthingmanager
pkg_config_dir=${config_dir}/${pkg}
rm ${pkg_config_dir}/${pkg}.conf
rmdir ${pkg_config_dir}
stman configure

# configure the local system
my_id=$(stman device list | grep "ID:" | head -n1 | cut -d: -f2 | tr -d "[:blank:]")
echo "local syncthing id is $my_id"
echo "please enter a name for this syncthing device:"
read name
stman device edit --name "${name}" -io "${my_id}"

# connect it to the mothership
stman device add \
  --name "${STMAN_ADD_DEVICE_NAME}" \
  --address "${STMAN_ADD_DEVICE_ADDRESS}" \
  "${STMAN_ADD_DEVICE_ID}"
echo "Please check ${STMAN_ADD_DEVICE_NAME} for a pair request, and share Passwords + SyncTemp"
