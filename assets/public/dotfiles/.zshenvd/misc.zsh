export EDITOR=vim
export PAGER=less
export TMPDIR=/tmp

# on Ubuntu, add Snappy to our path
if [ "Ubuntu" = "$(lsb_release --id --short)" ]; then
  export PATH="$PATH:/snap/bin"
fi

# https://doc.qt.io/qt-5/highdpi.html
# enables automatic scaling, based on the pixel density of the monitor.
export QT_AUTO_SCREEN_SCALE_FACTOR=1
