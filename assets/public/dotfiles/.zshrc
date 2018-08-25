# load per-topic rc files

files=( $HOME/.zshrcd/**/*sh )
for file in "${files[@]}"; do
  source "${file}"
done

unset file
unset files

