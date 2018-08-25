# load per-topic env files

files=( $HOME/.zshenvd/**/*sh )
for file in "${files[@]}"; do
  source "${file}"
done

unset file
unset files
