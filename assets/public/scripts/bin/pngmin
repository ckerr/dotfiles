#!/usr/bin/zsh

# Simple script to run a png through a pipeline of lossless png compressors
# to find the smallest output from all of them.
#
# The goal is the smallest losslessly-compressed file, so excessive switches
# are used, e.g. `advpng --shrink-insane`. This is computationally expensive.
#
# To run this on a file:
# $ pngmin.zsh filename.png
#
# To run this on a subtree:
# $ find ./ -name "*\.png" -print0 | xargs -0 -n1 -P `nproc` ./pngmin.zsh
#
# NB: The order of the cmds _might_ be important.
# See the "PNG (lossless) optimization programs" section of
# http://optipng.sourceforge.net/pngtech/optipng.html for details.

source="${1}"
template=pngmin-`basename --suffix='.png' "$source"`-XXXXXXXXXX
candidate=`mktemp --suffix='.png' ${template}`
# echo "${source}"
# echo "${candidate}"

TRAPINT() {
  rm --force --verbose "${candidate}"
  return 2
}

declare -a cmds=(
  "zopflipng -y \"$source\" \"$candidate\" 1>/dev/null"
  "optipng -clobber -preserve -quiet -o7 \"$candidate\""
  "advpng -q --shrink-insane --recompress \"$candidate\""
  "pngcrush -brute -reduce -ow -q \"$candidate\""
)

steps=${#cmds[@]}
for (( step = 1; step <= steps; step++ ))
do
  # echo "${step}/${steps} ${cmds[step]}"
  eval "${cmds[$step]}"
done

oldSize=$( stat -c %s "${source}" )
newSize=$( stat -c %s "${candidate}" )

if [[ ${newSize} -lt ${oldSize} ]]
then
  chmod --reference="${source}" "${candidate}"
  chown --reference="${source}" "${candidate}"
  mv --force "${candidate}" "${source}"
  echo "${oldSize} -> ${newSize} ${source}"
else
  rm --force "${candidate}"
fi
