function playalbum {
  declare -r albumdir="`xdg-user-dir MUSIC`/Albums"
  declare -r choice=`ls -1 "$albumdir" | sort --random-sort | tail -n1`
  mpv "$albumdir/$choice"
}
