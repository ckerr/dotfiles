# shortcuts
function figar0 {
  find ./ -type f -print0 | xargs -0 grep --color=always $1 | less -R
}


