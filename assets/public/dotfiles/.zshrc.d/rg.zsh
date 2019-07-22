
if [[ -x "/snap/bin/ripgrep.rg" ]]
then
  declare -r RG_PATH=/snap/bin/ripgrep.rg
else
  declare -r RG_PATH=(whence -c rg)
fi

function rg() {
  "$RG_PATH" $@
}

function rgup() {
  rg -uu --pretty $@ | less -RFX
}

# rgup matching most of the electron source types
function rgel() {
  rgup --type=cpp \
       --type=gn \
       --type=js \
       --type=markdown \
       --type=objcpp \
       --type=py \
       $@
}
