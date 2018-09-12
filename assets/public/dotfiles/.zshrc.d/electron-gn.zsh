#!/usr/bin/zsh

# Quick summary:
# elsync     : gets the source files and sets up the GN directory
# elmake     : builds Electron
# eltest     : runs the tests
# elfindexec : returns the path to Electron's executable
# elrg       : prettified grep in current directory
# elrgall    : prettified grep in all repos

 
##
##  Environment varibles
##


# arbitrary locations; can be wherever you like
export ELECTRON_GN_PATH="${HOME}/electron/electron-gn"
export ELECTRON_CACHE_PATH="${HOME}/.electron-cache"
export DEPOT_TOOLS_PATH="${HOME}/src/depot_tools"

# used by depot_tools/gclient
export GIT_CACHE_PATH="${ELECTRON_CACHE_PATH}/git-cache"
# used by sccache
export SCCACHE_DIR="${ELECTRON_CACHE_PATH}/sccache"
# used by electron's branch of sccache to share with CI
export SCCACHE_BUCKET="electronjs-sccache"
export SCCACHE_TWO_TIER=true
# used by chromium buildtools e.g. gn
export CHROMIUM_BUILDTOOLS_PATH="${ELECTRON_GN_PATH}/src/buildtools"

# depot tools needs to be in the path
if [ ! -d "${DEPOT_TOOLS_PATH}" ]; then
  echo 'depot tools not found!'
  echo 'how to install: http://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up'
elif [[ ":$PATH:" != *":$dir:"* ]]; then
  export PATH="${PATH}:${dir}"
  # see depot_tools/zsh-goodies/README
  fpath=("${DEPOT_TOOLS_PATH}/zsh-goodies" ${fpath})
fi


##
##  Directory setup
##


## ensure the directories exist
mkdir -p "${GIT_CACHE_PATH}"
mkdir -p "${SCCACHE_DIR}"
mkdir -p "${ELECTRON_GN_PATH}"


##
##  Utilities
##

# Gets the source and submodules.
# Use this to boostrap the first time and also after changing branches
elsync () {
  pushd "${ELECTRON_GN_PATH}"

  # if the .gclient file doesn't exist, then create it
  if [ ! -f "${ELECTRON_GN_PATH}/.gclient" ]; then
    gclient config --name 'src/electron' --unmanaged https://github.com/electron/electron
  fi

  # Get the code.
  # More reading:
  # https://www.chromium.org/developers/how-tos/get-the-code/working-with-release-branches

  gclient sync --with_branch_heads --with_tags --delete_unversioned_trees

  # ensure maintainer repos point to github instead of git-cache
  github_repos=( electron libchromiumcontent )
  for repo in "${github_repos[@]}"
  do
    dir="${ELECTRON_GN_PATH}/src/${repo}"
    url=$(git -C "${dir}" remote get-url origin)
    if [[ $url = *"${GIT_CACHE_PATH}"* ]]; then
      echo "setting github as origin for ${repo}"
      git -C "${dir}" remote set-url origin "git@github.com:electron/${repo}"
    fi
  done

  popd
}

# Builds Electron.
# First optional arg is the build config, e.g. "debug", "release", or "testing".
# See https://github.com/electron/electron/tree/master/build/args for full list.
#
# Examples:
#  elmake
#  elmake testing
elmake () {
  config="${1-debug}"

  build_dir="${ELECTRON_GN_PATH}/src/out/${config}"
  sccache="${ELECTRON_GN_PATH}/src/electron/external_binaries/sccache"

  # if the build configuration doesn't already exist, create it now
  if [ ! -d "${build_dir}" ]; then
    (cd "${ELECTRON_GN_PATH}/src" && gn gen "${build_dir}" --args="import(\"//electron/build/args/${config}.gn\") cc_wrapper=\"${sccache}\"")
  fi

  ninja -C "${build_dir}" electron:electron_app
  "${sccache}" --show-stats

}

# Runs the tests.
# First optional arg is the build config, e.g. "debug", "release", or "testing".
# See https://github.com/electron/electron/tree/master/build/args for full list.
# Remaining args are passed to the spec.
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
  build_dir="${ELECTRON_GN_PATH}/src/out/${config}"
  node_headers_dir="${build_dir}/gen/node_headers"
  electron_spec_dir="${ELECTRON_GN_PATH}/src/electron/spec"
  node_headers_need_rebuild='no'
  if [ ! -d "${node_headers_dir}" ]; then
    node_headers_need_rebuild='yes'
  elif [ "${electron_spec_dir}/package.json" -nt "${node_headers_dir}" ]; then
    node_headers_need_rebuild='yes'
  fi
  if [ "x$node_headers_need_rebuild" != 'xno' ]; then
    ninja -C "${build_dir}" third_party/electron_node:headers
    # Install the test modules with the generated headers
    (cd "${electron_spec_dir}" && npm i --nodedir="${node_headers_dir}")
    touch "${node_headers_dir}"
  fi

  electron=$(elfindexec "${config}")
  eltestrun "${electron}" "${electron_spec_dir}" ${@:2}
}

# Test runner utility.
# You probably want to use eltest() instead.
# This is useful iff you want to plug in arbitrary builds or specs.
eltestrun () {
  electron="$1"
  electron_spec_dir="$2"

  # if dbusmock is installed, start a mock dbus session for it
  dbusenv=''
  python -c "import dbusmock"
  if [ "$?" -eq '0' ]; then
    dbusenv=`mktemp -t electron.dbusmock.XXXXXXXXXX`
    echo "starting dbus @ ${dbusenv}"
    dbus-launch --sh-syntax > "${dbusenv}"
    cat "${dbusenv}" | sed 's/SESSION/SYSTEM/' >> "${dbusenv}"
    source "${dbusenv}"
    (python -m dbusmock --template logind &)
    (python -m dbusmock --template notification_daemon &)
  fi

  echo "starting ${electron}"
  "${electron}" "${electron_spec_dir}" ${@:2}

  # ensure this function cleans up after itself
  TRAPEXIT() {
    if [ -f "${dbusenv}" ]; then
      kill `grep DBUS_SESSION_BUS_PID "${dbusenv}" | sed 's/[^0-9]*//g'`
      rm "${dbusenv}"
    fi
  }
}

# find the Electron executable for a given configuration.
# First optional arg is the build config, e.g. "debug", "release", or "testing"
elfindexec () {
  config="${1-debug}"

  top="${ELECTRON_GN_PATH}/src/out/${config}"
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

elrg () {
  rg -t cpp -t js -t c -t objcpp -t md --unrestricted --pretty $@ | \
  less --quit-if-one-screen --no-init --RAW-CONTROL-CHARS
}

elrgall () {
  rg -t cpp -t js -t c -t objcpp -t md --unrestricted --pretty $@ "${ELECTRON_GN_PATH}/src" | \
  less --quit-if-one-screen --no-init --RAW-CONTROL-CHARS
}
