# Misc settings

export EDITOR=/usr/bin/vim
export PAGER=less
export LESS="--quit-at-eof --quit-if-one-screen --no-init --RAW-CONTROL-CHARS $LESS"
export TMPDIR=/tmp

# https://doc.qt.io/qt-5/highdpi.html
# enables automatic scaling, based on the pixel density of the monitor.
# export QT_AUTO_SCREEN_SCALE_FACTOR=1


# PATH building

prepend_to_path() {
  [ -d "${1}" ] || return 0
  case ":${PATH}:" in
    *":${1}:"*) return 0 ;;
  esac
  PATH="${1}:${PATH}"
  export PATH
}

prepend_to_path "${HOME}/opt/bin"
prepend_to_path "${HOME}/.local/bin"
prepend_to_path "${HOME}/bin"

case "$(uname)" in
  Linux)
    prepend_to_path /snap/bin
    ;;
  Darwin)
    prepend_to_path /usr/local/opt/findutils/libexec/gnubin
    # guard the subshell: without brew this used to run unconditionally
    # and spew an error on every login
    if command -v brew > /dev/null 2>&1; then
      prepend_to_path "$(brew --prefix llvm)/bin"
    fi
    ;;
esac


# MANPATH building

prepend_to_manpath() {
  [ -d "${1}" ] || return 0
  case ":${MANPATH:-}:" in
    *":${1}:"*) return 0 ;;
  esac
  MANPATH="${1}:${MANPATH:-}"
  export MANPATH
}

case "$(uname)" in
  Darwin)
    prepend_to_manpath /usr/local/opt/findutils/libexec/gnuman
    ;;
esac

unset -f prepend_to_path
unset -f prepend_to_manpath
