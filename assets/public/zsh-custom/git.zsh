function gcha {
  git ls-files -m -z | xargs -0 git checkout HEAD -- 
  git status
}

##
##

#function electron_cd {
#  #echo "$1"
#  cd "/home/charles/src/electron/electron/$1"
#  return 0
#}
#
#alias ecd18='electron_cd "1-8-x"'
#alias ecd17='electron_cd "1-7-x"'
#alias ecd2='electron_cd "2-0-x"'
#alias ecd3='electron_cd "3-0-x"'
#alias ecdm='electron_cd "master"'
