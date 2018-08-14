function greboot {
  git ls-files -m -z | xargs -0 git checkout HEAD -- 
  git status
}

function gpush {
  branch_name=`git rev-parse --abbrev-ref HEAD`
  git push --verbose origin "${branch_name}"
}

alias gumbo="git stash"

function git_repo_root {
  dir=`pwd`
  while [ "${dir}" != "/" ]; do
    if [ -d "${dir}/.git" ]; then
      echo "${dir}"
      return 0
    fi
    dir=`dirname "${dir}"`
  done
  echo "git repository root not found"
  return 1
}

#function gpullsub
#function gpullsub {
# ~/src/electron/electron/master/script  master ●  git submodule sync --recursive              1 ↵  2018-08-14 07:32:36 PDT wk33
#Synchronizing submodule url for '../vendor/boto'
#Synchronizing submodule url for '../vendor/breakpad'
#Synchronizing submodule url for '../vendor/crashpad'
#Synchronizing submodule url for '../vendor/depot_tools'
#Synchronizing submodule url for '../vendor/gyp'
#Synchronizing submodule url for '../vendor/libchromiumcontent'
#Synchronizing submodule url for '../vendor/libchromiumcontent/vendor/boto'
#Synchronizing submodule url for '../vendor/libchromiumcontent/vendor/depot_tools'
#Synchronizing submodule url for '../vendor/libchromiumcontent/vendor/pyyaml'
#Synchronizing submodule url for '../vendor/node'
#Synchronizing submodule url for '../vendor/pdf_viewer'
#Synchronizing submodule url for '../vendor/pdf_viewer/vendor/grit'
#Synchronizing submodule url for '../vendor/requests'
# ~/src/electron/electron/master/script  master ●  git submodule update --init --recursive       ✔  2018-08-14 07:32:40 PDT wk33

