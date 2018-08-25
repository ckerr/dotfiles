export PAGER=less
export EDITOR=vim
export TMPDIR=/tmp

if [[ -d /snap/bin ]]; then
  export PATH="$PATH:/snap/bin"
fi
