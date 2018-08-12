function electron_root {
  dir=`pwd`
  while [ "${dir}" != "/" ]; do
    file="${dir}/package.json"
    if [ -f "${file}" ]; then
      lines=`grep '"name": "electron"' "${file}" | wc --lines`
      if [ "${lines}" -eq "1" ]; then
        echo "$dir"
        return 0
      fi
    fi
    dir=`dirname "${dir}"`
  done
  echo "electron root not found"
  return 1
}

function electron_distclean {
  pushd "$(electron_root)"
  python ./script/clean.py
  popd
}

function electron_bootstrap_dev {
  pushd "$(electron_root)"
  ./script/bootstrap.py --dev --verbose
  popd
}

function electron_build_debug {
  pushd "$(electron_root)"
  ./script/build.py -c Debug
  popd
}

alias er=electron_root
alias eclean=electron_distclean
alias eboot=electron_bootstrap_dev
alias ebuild=electron_build_debug

##
##

function electron_cd {
  #echo "$1"
  cd "/home/charles/src/electron/electron/$1"
  return 0
}

alias ecd18='electron_cd "1-8-x"'
alias ecd17='electron_cd "1-7-x"'
alias ecd2='electron_cd "2-0-x"'
alias ecd3='electron_cd "3-0-x"'
alias ecdm='electron_cd "master"'
