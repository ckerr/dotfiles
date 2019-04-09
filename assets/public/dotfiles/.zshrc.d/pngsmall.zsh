function pngsmall {
  for source in "$@"
  do
    lossless=`basename --suffix='.png' "$source"`-lossless.png
    lossy=`basename --suffix='.png' "$source"`-lossy.png

    declare -a commands=(
      "zopflipng -y \"$source\" \"$lossless\" 1>/dev/null"
      "advpng -q --shrink-insane --recompress \"$lossless\""
      "pngcrush -brute -reduce -ow -q \"$lossless\""
      "optipng -clobber -preserve -quiet -o7 \"$lossless\""
      "pngquant --output \"$lossy\" --force --skip-if-larger --speed=1 \"$lossless\""
    )

    steps=${#commands[@]}
    for (( step = 1; step <= steps; step++ ))
    do
      echo "${step}/${steps} ${commands[step]}"
      eval "${commands[$step]}"
    done

    ls -lS "$source" "$lossless" "$lossy"
  done
}
