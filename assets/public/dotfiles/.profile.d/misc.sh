# Misc settings

export EDITOR=/usr/bin/vim
export PAGER=less
export LESS="--quit-if-one-screen --no-init $LESS"
export TMPDIR=/tmp

# https://doc.qt.io/qt-5/highdpi.html
# enables automatic scaling, based on the pixel density of the monitor.
# export QT_AUTO_SCREEN_SCALE_FACTOR=1


# Cache directory

XDG_CACHE_HOME="${TMPDIR}/charles-cache"
if [ ! -d ${XDG_CACHE_HOME} ]; then
  mkdir -m 700 "${XDG_CACHE_HOME}"
fi
export XDG_CACHE_HOME


# PATH building

bindirs=(
  "${HOME}"/opt/bin
  "${HOME}"/.local/bin
  "${HOME}"/bin
)

if [[ x`uname` == 'xLinux' ]]; then
  bindirs+=(/snap/bin)
fi

if [[ x`uname` == 'xDarwin' ]]; then
  bindirs+=(/usr/local/opt/findutils/libexec/gnubin)
  bindirs+=($(brew --prefix llvm)/bin)
fi

for bindir in "${bindirs[@]}"
do
  if [[ ":$PATH:" != *":$bindir:"* ]]; then
    if [ -d "${bindir}" ]; then
      export PATH="${bindir}:${PATH}"
    fi
  fi
done


# MANPATH building

manpathdirs=(
)

if [[ x`uname` == 'xDarwin' ]]; then
  manpathdirs+=(/usr/local/opt/findutils/libexec/gnuman)
fi

for manpathdir in "${manpathdirs[@]}"
do
  if [[ ":$MANPATH:" != *":$manpathdir:"* ]]; then
    if [[ -d "${manpathdir}" ]]; then
      export MANPATH="${manpathdir}:${MANPATH}"
    fi
  fi
done


