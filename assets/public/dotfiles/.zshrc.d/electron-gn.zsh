#!/usr/bin/zsh

# Quick summary:
# elsync     : gets the source files and sets up the GN directory
# elmake     : builds Electron
# eltest     : runs the tests
# elfindexec : returns the path to Electron's executable
# elrg       : prettified grep in current directory
# elrgall    : prettified grep in all repos

 
##
##  build-tools setup
##

# ensure build-tools is installed
BUILD_TOOLS_ROOT="${HOME}/electron/build-tools"
if [[ ! -d "${BUILD_TOOLS_ROOT}" ]]; then
  git clone 'git@github.com:electron/build-tools.git' "${BUILD_TOOLS_ROOT}"
fi
# ensure build-tools is in PATH
if [[ ":$PATH:" != *":${BUILD_TOOLS_ROOT}/src:"* ]]; then
  export PATH="${PATH}:${BUILD_TOOLS_ROOT}/src"
fi
unset BUILD_TOOLS_ROOT

# ensure build-tools' config dir is in XDG_CONFIG_HOME
if [[ -z "${EVM_CONFIG}" ]]; then
  export EVM_CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/evm-config"
fi

#ensure build-tools' config dir exists
if [[ ! -d "${EVM_CONFIG}" ]]; then
  mkdir -p "${EVM_CONFIG}"
fi


##
##  utilities
##

# Gets the source and submodules.
# Use this to boostrap the first time and also after changing branches
elsync () {
  # Get the code.
  # More reading:
  # https://www.chromium.org/developers/how-tos/get-the-code/working-with-release-branches
  e sync \
    --break_repo_locks \
    --delete_unversioned_trees \
    --lock_timeout=300 \
    --with_branch_heads \
    --with_tags \
    -vvvv
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
    (cd "${ELECTRON_GN_PATH}/src" && CHROMIUM_BUILDTOOLS_PATH="${ELECTRON_GN_PATH}"/src/buildtools gn gen "${build_dir}" --args="${gn_args}")
  fi

  # if there's nothing to do, exit without showing sccache stats
  local -r target='electron:electron_app'
  ninja -C "${build_dir}" -n "${target}" | grep --color=never 'no work to do'
  if [[ $? -eq 0 ]]; then
    return 0
  fi

  # if the build fails, return the error
  ninja ${@:2} -C "${build_dir}" "${target}"
  local -r code=$?
  if [[ $code -ne 0 ]]; then
    return $code
  fi

  "${sccache}" --show-stats
}

# FIXME: should any of this be ported to build-tools or e/e's scripts dir?
# spec-runner already kicks off a dbusmock
#eltestrun () {
#  local -r electron="$1"
#  local -r electron_spec_dir="$2"
#
#  # if dbusmock is installed, start a mock dbus session for it
#  python -c 'import dbusmock'
#  if [ "$?" -eq '0' ]; then
#    local -r dbusenv=`mktemp -t electron.dbusmock.XXXXXXXXXX`
#    echo "starting dbus @ ${dbusenv}"
#    dbus-launch --sh-syntax > "${dbusenv}"
#    cat "${dbusenv}" | sed 's/SESSION/SYSTEM/' >> "${dbusenv}"
#    source "${dbusenv}"
#    (python -m dbusmock --template logind &)
#    (python -m dbusmock --template notification_daemon &)
#  else
#    local -r dbusenv=''
#  fi
#
#  echo "starting ${electron}"
#  "${electron}" "${electron_spec_dir}" ${@:2}
#
#  # ensure this function cleans up after itself
#  TRAPEXIT() {
#    if [ -f "${dbusenv}" ]; then
#      kill `grep DBUS_SESSION_BUS_PID "${dbusenv}" | sed 's/[^0-9]*//g'`
#      rm "${dbusenv}"
#    fi
#  }
#}

# find the Electron executable for a given configuration.
# First optional arg is the build config, e.g. 'debug', 'release', or 'testing'
elfindexec () {
  e show exe
}

elrg () {
  rg -t cpp -t js -t c -t objcpp -t md -uu --pretty $@ "$(e show src)" | less -RFX
}

elrgall () {
  rg -t cpp -t js -t c -t objcpp -t md -uu --pretty $@ "$(e show src '.')" | less -RFX
}

elroot () {
  cd $(e show src '.')
  elcwd
}

# use: `elsrc` to cd to electron src directory
# use: `elsrc $dir` to cd to electron src sibling directory e.g. `elsrc base`
elsrc () {
  local -r dir="${1-electron}"

  cd $(e show src "${dir}")
  elcwd
}

# run electron
# @param config (default:debug)
# @param path (default:.)
elrun () {
  e run "$@"

  # FIXME move this to build-tools
  #nm -an "${electron}" | grep --quiet '__asan_init$'
  #if [ $? -eq 0 ]; then
  #  local -r is_asan='yes'
  #else
  #  local -r is_asan='no'
  #fi
  #
  #if [ "x$is_asan" = 'xyes' ]; then
  #  local -r symbolize="${ELECTRON_GN_PATH}/src/tools/valgrind/asan/asan_symbolize.py"
  #  echo "piping output to ${symbolize}"
  #  "${electron}" "${dir}" 2>&1 | "${symbolize}" --executable-path="${electron}"
  #else
  #  "${electron}" "${dir}"
  #fi
}

# run electron inside a debugger in the specified directory
# @param path (default:.)
eldebug () {
  local -r dir="${1-.}"

  # FIXME: consider porting to build-tools? Is there an lldb equivalent?
  e debug -ex "r '${dir}'"
}

# run electron inside a debugger in the specified directory
# with a breakpoint set to `main()`
# @param path (default:.)
eldebugmain () {
  local -r dir="${1-.}"

  e debug -ex 'set breakpoint pending on' \
          -ex 'break main' \
          -ex "r '${dir}'"
}
 
# make a fresh build, then run it in the specified directory
# @param path (default:.)
elmakerun () {
  local -r dir="${1-.}"

  e make && e run "${dir}"
}

# make a fresh build, then run it inside a debugger in the specified directory
# @param path (default:.)
elmakedebug () {
  local -r dir="${1-.}"

  e make && eldebug "${dir}"
}

# make a fresh build, then run it inside a debugger in the specified directory
# with a breakpoint set for `main()`
# @param path (default:.)
elmakedebugmain () {
  local -r dir="${1-.}"

  e make && eldebugmain "${dir}"
}

# shortcut to get a clone of `electron-quick-start`
elquick () {
  local -r target=${1-electron-quick-start}

  git clone git@github.com:electron/electron-quick-start.git "${target}" && cd "${target}" && npm install
}

# find the name of the config matching this directory
__el_config_for_dir () {
  local -r test_dir="${1-$PWD}"

  # get config dir
  local evmdir="$EVM_CONFIG"
  if [[ -z "$evmdir" ]]; then
    evmdir=$(which e)
    evmdir=$(dirname "${evmdir}")
    evmdir=$(git -C "$evmdir" rev-parse --show-toplevel)
  fi

  # check configs for a root that matches the test dir
  for file in $evmdir/evm\.*\.json; do
    local root=$(json root -f "$file")
    if [[ "${test_dir##$root}" != "$test_dir" ]]; then
      local -r name=$(echo "$file" | sed 's/.*\/evm\.//' | sed 's/\.json$//')
      echo "$name"
      return
    fi
  done
}

# show the build config status for the current directory
elcwd () {
  local -r dir="${1-$PWD}"
  local -r dir_cfg=$(__el_config_for_dir "$dir")
  if [[ ! -z "$dir_cfg" ]]; then
    local -r cur_cfg=$(e show current)
    if [[ "$cur_cfg" == "$dir_cfg" ]]; then
      e show current -g
    else
      e use "$dir_cfg" &>/dev/null
      e show current -g
      e use "$cur_cfg" &>/dev/null
    fi
  fi
}


alias eld=eldebug
alias eldma=eldebugmain
alias elm=elmake
alias elmd=elmakedebug
alias elmdma=elmakedebugmain
alias elmr=elmakerun
alias elr=elrun
