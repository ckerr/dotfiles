#!/usr/bin/env zsh

whence gfind
if [ $? -eq 0 ]; then
  gfind=gfind
  ginstall=ginstall
else
  gfind=find
  ginstall=install
fi

(cd assets/public/dotfiles \
  && $gfind -name ".[^.]*"    -type f -exec $ginstall -Dm 644 "{}" "${HOME}/{}" \; -print \
  && $gfind -path ".[^.]*/**" -type f -exec $ginstall -Dm 644 "{}" "${HOME}/{}" \; -print )

(cd assets/private/dotfiles \
  && $gfind -name ".[^.]*"    -type f -exec $ginstall -Dm 600 "{}" "${HOME}/{}" \; -print \
  && $gfind -path ".[^.]*/**" -type f -exec $ginstall -Dm 600 "{}" "${HOME}/{}" \; -print )

echo $0 done
