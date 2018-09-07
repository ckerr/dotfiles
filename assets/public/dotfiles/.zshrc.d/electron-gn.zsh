#!/usr/bin/zsh


##
##  Environment varibles
##


# arbitrary locations; can be whatever you like
export ELECTRON_GN_HOME="${HOME}/electron/electron-gn"
export ELECTRON_CACHE_HOME="${HOME}/.electron-cache"

# used by depot_tools/gclient
export GIT_CACHE_PATH="${ELECTRON_CACHE_HOME}/git-cache"
# used by sccache
export SCCACHE_DIR="${ELECTRON_CACHE_HOME}/sccache"
# used by electron's branch of sccache to share with CI
export SCCACHE_BUCKET="electronjs-sccache"
export SCCACHE_TWO_TIER=true

# if we can find depot tools, make sure it's in our path
dir="${DEPOT_TOOLS-$HOME/src/depot_tools}"
echo $dir
if [ -d ${dir} ]; then
  if [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="${PATH}:${dir}"
  fi
fi


##
##  Directory setup
##


## ensure the directories exist
mkdir -p "${GIT_CACHE_PATH}"
mkdir -p "${SCCACHE_DIR}"
mkdir -p "${ELECTRON_GN_HOME}"


##
##  Utilities
##

# Gets the source and sets up the GN directory
elsync () {
  cd "${ELECTRON_GN_HOME}"
  gclient config --name "src/electron" --unmanaged https://github.com/electron/electron --verbose
  gclient sync --with_branch_heads --with_tags --verbose
}

# Generates the build configuration
# First optional arg is the build config, e.g. "debug", "release", or "testing"
elgen () {
  config="${1-debug}"

  cd "${ELECTRON_GN_HOME}/src"
  export CHROMIUM_BUILDTOOLS_PATH="`pwd`/buildtools"
  gn gen "out/${config}" --args="import(\"//electron/build/args/${config}.gn\") cc_wrapper=\"`pwd`/electron/external_binaries/sccache\""
}

# Builds Electron.
# First optional arg is the build config, e.g. "debug", "release", or "testing"
elmake () {
  config="${1-debug}"

  cd "${ELECTRON_GN_HOME}/src"
  ninja -C "out/${config}" electron:electron_app
  "${ELECTRON_GN_HOME}/src/electron/external_binaries/sccache" -s 
}

# Runs the tests.
# First optional arg is the build config, e.g. "debug", "release", or "testing"
# Remaining args are passed to the spec
#
# Examples:
#  eltest
#  eltest testing
#  eltest debug
#  eltest debug --ci -g powerMonitor
eltest () {

  config="${1-debug}"

  # to run the tests, you'll first need to build the test modules
  # against the same version of Node.js that was built as part of
  # the build process.
  node_headers_dir="${ELECTRON_GN_HOME}/src/out/${config}/gen/node_headers"
  electron_spec_dir="${ELECTRON_GN_HOME}/src/electron/spec"
  need_rebuild='no'
  if [ ! -d "${node_headers_dir}" ]; then
    need_rebuild='yes'
  elif [ "${electron_spec_dir}/package.json" -nt "${node_headers_dir}" ]; then
    need_rebuild='yes'
  fi
  if [ "x$need_rebuild" != 'xno' ]; then
    ninja -C "out/${config}" third_party/electron_node:headers
    # Install the test modules with the generated headers
    (cd "${electron_spec_dir}" && npm i --nodedir="${node_headers_dir}")
    touch "${node_headers_dir}"
  fi

  # if dbusmock is insalled, start a mock dbus session for it
  dbusenv=''
  have_dbusmock=`pip list --format=legacy | grep dbusmock | wc --lines`
  if [ "x${have_dbusmock}" == 'x1' ]; then
    dbusenv="${TMPDIR-/tmp}/dbus.env"
    rm -f "${dbusenv}"
    dbus-launch --sh-syntax > "${dbusenv}"
    cat "${dbusenv}" | sed "s/SESSION/SYSTEM/" >> "${dbusenv}"
    cat "${dbusenv}"
    source "${dbusenv}"
    python -m dbusmock --template logind &
    python -m dbusmock --template notification_daemon &
    env | grep DBUS
  fi

  cd "${ELECTRON_GN_HOME}/src"
  $(elfindexec "${config}") "${electron_spec_dir}" ${@:2}

  # ensure that this function cleans up after itself
  TRAPEXIT() {
    if [ -f "${dbusenv}" ]; then
      kill `grep DBUS_SESSION_BUS_PID /tmp/dbus.env | sed "s/[^0-9]*//g"`
      rm "${dbusenv}"
    fi
  }
}

elfindexec () {
  config="${1-debug}"

  top="${ELECTRON_GN_HOME}/src/out/${config}"
  dirs=("${top}/Electron.app/Contents/MacOS/Electron" \
        "${top}/electron.exe" \
        "${top}/electron")
  for dir in "${dirs[@]}"
  do
    if [ -x "${dir}" ]; then
      echo "${dir}"
      return 0
    fi
  done
  echo /dev/null
  return 1
}
