arrsync () {
  rsync -a --partial --info=progress2 $@
}
