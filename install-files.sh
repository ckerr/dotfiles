#!/usr/bin/env bash

. ./common.sh

(cd assets/public/dotfiles \
  && $gfind -name ".[^.]*"    -type f -exec $ginstall -Dm 644 "{}" "${HOME}/{}" \; -print \
  && $gfind -path ".[^.]*/**" -type f -exec $ginstall -Dm 644 "{}" "${HOME}/{}" \; -print )

(cd assets/private/dotfiles \
  && $gfind -name ".[^.]*"    -type f -exec $ginstall -Dm 600 "{}" "${HOME}/{}" \; -print \
  && $gfind -path ".[^.]*/**" -type f -exec $ginstall -Dm 600 "{}" "${HOME}/{}" \; -print )

(cd assets/public/scripts \
  && $gfind -name ".[^.]*"    -type f -exec $ginstall "{}" "${HOME}/{}" \; -print \
  && $gfind -path ".[^.]*/**" -type f -exec $ginstall "{}" "${HOME}/{}" \; -print )

echo $0 done
