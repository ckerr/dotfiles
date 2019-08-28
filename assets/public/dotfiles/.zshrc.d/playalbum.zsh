function playalbum {
  declare -r albums_dir="`xdg-user-dir MUSIC`/Albums"
  declare -r album=`ls -1 "$albums_dir" | sort --random-sort | head --lines=1`
  mpv --quiet "$albums_dir/$album"
}
