# load per-topic rc files

files=( $HOME/.zshrc.d/*sh )
for file in "${files[@]}"; do
  source "${file}"
done

unset file
unset files

