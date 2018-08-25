export EDITOR=vim
export PAGER=less
export TMPDIR=/tmp

# on Ubuntu, add Snappy to our path
if [ "Ubuntu" = "$(lsb_release --id --short)" ]; then
  export PATH="$PATH:/snap/bin"
fi
