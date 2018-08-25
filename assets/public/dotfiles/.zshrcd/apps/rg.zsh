function rgup() {
  rg --unrestricted --pretty "$@" | less -RFX
}

if [[ -x "/snap/bin/ripgrep.rg" ]]
then
  export RG_PATH=/snap/bin/ripgrep.rg
else
  export RG_PATH=(whence -c rg)
fi

function rg() {
  "$RG_PATH" $@
}
