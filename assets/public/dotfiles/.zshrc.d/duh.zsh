function duh {
  if [ $# -ne 0 ]; then
    du -sh $@ | sort -h
  else
    du -sh * | sort -h
  fi
}

