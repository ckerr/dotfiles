# load per-topic env files

files=( $HOME/.zshenvd/**/*sh $HOME/.zshenvd/*sh )
for file in "${files[@]}"; do
  echo "${file}"
  source "${file}"
done

unset file
unset files
