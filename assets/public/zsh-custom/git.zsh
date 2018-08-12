function gcha {
  git ls-files -m -z | xargs -0 git checkout HEAD -- 
  git status
}

function gpo {
  branch_name=`git rev-parse --abbrev-ref HEAD`
  git push --verbose origin "${branch_name}"
}
