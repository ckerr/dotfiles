function version {
  if [ $# -ne 1 ]; then
    echo 'usage: version appname'
  else
    local version=''
    # does dpkg know about it?
    if [ -z "${version}" ] && [ ! -z $(command -v dpkg) ]; then
      version=$(dpkg -s $1 2>/dev/null | grep '^Version:' | sed 's/ \+/ /g' | cut -d ' ' -f2)
    fi
    # does snap know about it?
    if [ -z "${version}" ] && [ ! -z $(command -v snap) ]; then
      version=$(snap list $1 2>/dev/null | grep ^$1 | sed 's/ \+/ /g' | cut -d ' ' -f2)
    fi
    echo $version
  fi
}
