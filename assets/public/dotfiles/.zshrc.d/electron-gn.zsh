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
export SCCACHE_BUCKET='electronjs-sccache'
export SCCACHE_TWO_TIER=true
# used by chromium buildtools e.g. gn
export CHROMIUM_BUILDTOOLS_PATH="${ELECTRON_GN_PATH}/src/buildtools"

if [[ "${OSTYPE}" = *linux* ]]; then
  # the specs won't run on Linux without this
  export ELECTRON_DISABLE_SECURITY_WARNINGS=1
fi

# depot tools needs to be in the path
if [ ! -d "${DEPOT_TOOLS_PATH}" ]; then
  echo 'depot tools not found!'
  echo 'how to install: http://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up'
elif [[ ":$PATH:" != *":${DEPOT_TOOLS_PATH}:"* ]]; then
  export PATH="${PATH}:${DEPOT_TOOLS_PATH}"
  # see depot_tools/zsh-goodies/README
  fpath=("${DEPOT_TOOLS_PATH}/zsh-goodies" ${fpath})
fi


##
##  Directory setup
##

# IIFE to ensure the directories exist
function() {
  if [ 'x' != "x$(command -v gmkdir)" ]; then
    local -r gmkdir='gmkdir'
  else
    local -r gmkdir='mkdir'
  fi
  "${gmkdir}" -p "${GIT_CACHE_PATH}"
  "${gmkdir}" -p "${SCCACHE_DIR}"
  "${gmkdir}" -p "${ELECTRON_GN_PATH}"
}

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

  gclient sync --with_branch_heads --with_tags --delete_unversioned_trees -vvvv --break_repo_locks --lock_timeout=300

  # ensure maintainer repos point to github instead of git-cache
  repo=electron
  dir="${ELECTRON_GN_PATH}/src/${repo}"
  url=$(git -C "${dir}" remote get-url origin)
  if [[ $url = *"${GIT_CACHE_PATH}"* ]]; then
    local -r origin_url="git@github.com:electron/${repo}"
    echo "setting ${repo} origin to ${origin_url}"
    git -C "${dir}" remote set-url        origin "${origin_url}"
    git -C "${dir}" remote set-url --push origin "${origin_url}"
  fi

  popd
}

# Builds Electron.
# First optional arg is the build config, e.g. 'debug', 'release', or 'testing'.
# See https://github.com/electron/electron/tree/master/build/args for full list.
# As a special case, a config of 'asan' will make an asan-enabled testing release
#
# Examples:
#  elmake
#  elmake testing
elmake () {
  local config="${1-debug}"

  local -r build_dir="${ELECTRON_GN_PATH}/src/out/${config}"
  local -r sccache="${ELECTRON_GN_PATH}/src/electron/external_binaries/sccache"

  if [ "x${config}" = 'xasan' ]; then
    config='testing' # asan builds must use testing config
    local -r is_asan='yes'
  else
    local -r is_asan='no'
  fi

  # if the build dir hasn't been generated already, generate it now
  if [ ! -d "${build_dir}" ]; then
    local gn_args="import(\"//electron/build/args/${config}.gn\") "
    gn_args+="cc_wrapper=\"${sccache}\" "
    if [ "x${is_asan}" = 'xyes' ]; then
      gn_args+='is_asan=true '
    fi
    echo "${gn_args}"
    (cd "${ELECTRON_GN_PATH}/src" && gn gen "${build_dir}" --args="${gn_args}")
  fi

  # if there's nothing to do, exit without showing sccache stats
  local -r target='electron:electron_app'
  ninja -C "${build_dir}" -n "${target}" | grep --color=never 'no work to do'
  if [[ $? -eq 0 ]]; then
    return 0
  fi

  # if the build fails, return the error
  ninja -C "${build_dir}" "${target}"
  local -r code=$?
  if [[ $code -ne 0 ]]; then
    return $code
  fi

  "${sccache}" --show-stats
}

# Runs the tests.
# First optional arg is the build config, e.g. 'debug', 'release', or 'testing'.
# See https://github.com/electron/electron/tree/master/build/args for full list.
# Remaining args are passed to the spec.
#
# Examples:
#  eltest
#  eltest testing
#  eltest debug
#  eltest debug --ci -g powerMonitor
eltest () {
  local -r config="${1-debug}"

  # to run the tests, you'll first need to build the test modules
  # against the same version of Node.js that was built as part of
  # the build process.
  local -r build_dir="${ELECTRON_GN_PATH}/src/out/${config}"
  local -r node_headers_dir="${build_dir}/gen/node_headers"
  local -r electron_spec_dir="${ELECTRON_GN_PATH}/src/electron/spec"

  if [ ! -d "${node_headers_dir}" ]; then
    local -r node_headers_need_rebuild='yes'
  elif [ "${electron_spec_dir}/package.json" -nt "${node_headers_dir}" ]; then
    local -r node_headers_need_rebuild='yes'
  else
    local -r node_headers_need_rebuild='no'
  fi

  if [ "x$node_headers_need_rebuild" != 'xno' ]; then
    ninja -C "${build_dir}" third_party/electron_node:headers
    # Install the test modules with the generated headers
    (cd "${electron_spec_dir}" && npm i --nodedir="${node_headers_dir}")
    touch "${node_headers_dir}"
  fi

  local -r electron=$(elfindexec "${config}")
  eltestrun "${electron}" "${electron_spec_dir}" ${@:2}
}

# Test runner utility.
# You probably want to use eltest() instead.
# This is useful iff you want to plug in arbitrary builds or specs.
eltestrun () {
  local -r electron="$1"
  local -r electron_spec_dir="$2"

  # if dbusmock is installed, start a mock dbus session for it
  python -c 'import dbusmock'
  if [ "$?" -eq '0' ]; then
    local -r dbusenv=`mktemp -t electron.dbusmock.XXXXXXXXXX`
    echo "starting dbus @ ${dbusenv}"
    dbus-launch --sh-syntax > "${dbusenv}"
    cat "${dbusenv}" | sed 's/SESSION/SYSTEM/' >> "${dbusenv}"
    source "${dbusenv}"
    (python -m dbusmock --template logind &)
    (python -m dbusmock --template notification_daemon &)
  else
    local -r dbusenv=''
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
# First optional arg is the build config, e.g. 'debug', 'release', or 'testing'
elfindexec () {
  local -r config="${1-debug}"

  local -r top="${ELECTRON_GN_PATH}/src/out/${config}"
  local -r dirs=("${top}/Electron.app/Contents/MacOS/Electron" \
                 "${top}/electron.exe" \
                 "${top}/electron")
  local dir
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
  rg -t cpp -t js -t c -t objcpp -t md -uu --pretty $@ | less -RFX
}

elrgall () {
  rg -t cpp -t js -t c -t objcpp -t md -uu --pretty $@ "${ELECTRON_GN_PATH}/src" | less -RFX
}

# use: `elsrc` to cd to electron src directory
# use: `elsrc $dir` to cd to electron src sibling directory e.g. `elsrc base`
elsrc () {
  local -r dir=${1-electron}

  cd "${ELECTRON_GN_PATH}/src/${dir}"
}

# run electron
# @param config (default:debug)
# @param path (default:.)
elrun () {
  local -r config="${1-debug}"
  local -r dir="${2-.}"

  local -r electron=$(elfindexec "${config}")

  nm -an "${electron}" | grep --quiet '__asan_init$'
  if [ $? -eq 0 ]; then
    local -r is_asan='yes'
  else
    local -r is_asan='no'
  fi

  if [ "x$is_asan" = 'xyes' ]; then
    local -r symbolize="${ELECTRON_GN_PATH}/src/tools/valgrind/asan/asan_symbolize.py"
    echo "piping output to ${symbolize}"
    "${electron}" "${dir}" 2>&1 | "${symbolize}" --executable-path="${electron}"
  else
    "${electron}" "${dir}"
  fi
}

# run electron inside a debugger in the specified directory
# @param config (default:debug)
# @param path (default:.)
eldebug () {
  local -r config="${1-debug}"
  local -r dir="${2-.}"

  local -r electron=$(elfindexec "${config}")
  gdb "${electron}" -ex "source ${ELECTRON_GN_PATH}/src/tools/gdb/gdbinit" \
                    -ex "r '${dir}'"
}

# run electron inside a debugger in the specified directory
# with a breakpoint set to `main()`
# @param config (default:debug)
# @param path (default:.)
eldebugmain () {
  local -r config="${1-debug}"
  local -r dir="${2-.}"

  local -r electron=$(elfindexec "${config}")
  gdb "${electron}" -ex "source ${ELECTRON_GN_PATH}/src/tools/gdb/gdbinit" \
                    -ex 'set breakpoint pending on' \
                    -ex 'break main' \
                    -ex "r '${dir}'"
}
 
# make a fresh build, then run it in the specified directory
# @param config (default:debug)
# @param path (default:.)
elmakerun () {
  local -r config="${1-debug}"
  local -r dir="${2-.}"

  elmake "${config}" && elrun "${config}" "${dir}"
}

# make a fresh build, then run it inside a debugger in the specified directory
# @param config (default:debug)
# @param path (default:.)
elmakedebug () {
  local -r config="${1-debug}"
  local -r dir="${2-.}"

  elmake "${config}" && eldebug "${config}" "${dir}"
}

# make a fresh build, then run it inside a debugger in the specified directory
# with a breakpoint set for `main()`
# @param config (default:debug)
# @param path (default:.)
elmakedebugmain () {
  local -r config="${1-debug}"
  local -r dir="${2-.}"

  elmake "${config}" && eldebugmain "${config}" "${dir}"
}

# shortcut to get a clone of `electron-quick-start`
elquick () {
  local -r target=${1-electron-quick-start}

  git clone git@github.com:electron/electron-quick-start.git "${target}" && cd "${target}" && npm install
}

alias eld=eldebug
alias eldma=eldebugmain
alias elm=elmake
alias elmd=elmakedebug
alias elmdma=elmakedebugmain
alias elmr=elmakerun
alias elr=elrun


