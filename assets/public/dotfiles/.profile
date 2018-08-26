# load per-topic env files

files=( $HOME/.profile.d/*sh )
for file in "${files[@]}"; do
  source "${file}"
done

unset file
unset files
