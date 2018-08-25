# Misc settings

export EDITOR=/usr/bin/vim
export PAGER=less
export TMPDIR=/tmp

# https://doc.qt.io/qt-5/highdpi.html
# enables automatic scaling, based on the pixel density of the monitor.
export QT_AUTO_SCREEN_SCALE_FACTOR=1


# PATH building

## Snappy
if [ "Ubuntu" = "$(lsb_release --id --short)" ]; then
  export PATH="$PATH:/snap/bin"
fi

## Personal bindirs
personal_bindirs = (
  $HOME/opt/bin
  $HOME/.local/bin
  $HOME/bin
)

for bindir in "${personal_bindirs[@]}"
do
  if [ -d "${bindir}" ]; then
    export PATH="${bindir}:${PATH}"
  fi
done
