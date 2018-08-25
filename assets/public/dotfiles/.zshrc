# load per-topic rc files

files=( $HOME/.zshrcd/**/*sh $HOME/.zshrcd/*sh )
for file in "${files[@]}"; do
  echo "${file}"
  source "${file}"
done

unset file
unset files

