function pngsmall {
  lossless=`basename --suffix='.png' "$1"`-lossless.png
  lossy=`basename --suffix='.png' "$1"`-lossy.png
  cp "$1" "$lossless"

  step=0
  steps=5

  # these are lossless tools

  ((++step))
  echo "${step}/${steps} advpng"
  advpng --shrink-insane --recompress "$lossless"

  ((++step))
  echo "${step}/${steps} pngcrush"
  pngcrush -brute -reduce -ow -q "$lossless"

  ((++step))
  echo "${step}/${steps} zopflipng"
  zopflipng -y "$lossless" "$lossless"

  ((++step))
  echo "${step}/${steps} optipng"
  optipng -clobber -preserve -quiet -o7 "$lossless"

  # lossy tools
  cp "$lossless" "$lossy"

  ((++step))
  echo "${step}/${steps} pngquant"
  pngquant --output "$lossy" --force --skip-if-larger --speed=1 "$lossy"
}


