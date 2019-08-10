function dudir {
  du -ha -d1 . | sort -h
}

function dush {
  du -sh -- $@ | sort -h
}
