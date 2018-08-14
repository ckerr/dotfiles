alias electron_root=git_repo_root

function electron_run_tests {
  pushd "$(electron_root)"
  if [ $# -eq 0 ]
  then
    MOCHA_REPORTER=spec npm run test -- --ci
  else
    MOCHA_REPORTER=spec npm run test -- --ci -g "$1"
  fi
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
alias etest=electron_run_tests
alias etests=etest

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
