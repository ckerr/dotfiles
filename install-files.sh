#!/usr/bin/env bash

. ./common.sh

(cd assets/public/dotfiles \
  && $gfind -name ".[^.]*"    -type f -exec $ginstall -D "{}" "${HOME}/{}" \; -print \
  && $gfind -path ".[^.]*/**" -type f -exec $ginstall -D "{}" "${HOME}/{}" \; -print )

(cd assets/private/dotfiles \
  && $gfind -name ".[^.]*"    -type f -exec $ginstall -D "{}" "${HOME}/{}" \; -print \
  && $gfind -path ".[^.]*/**" -type f -exec $ginstall -D "{}" "${HOME}/{}" \; -print )

(cd assets/public/scripts \
  && $gfind -name ".[^.]*"    -type f -exec $ginstall "{}" "${HOME}/{}" \; -print \
  && $gfind -path ".[^.]*/**" -type f -exec $ginstall "{}" "${HOME}/{}" \; -print )

echo $0 done
