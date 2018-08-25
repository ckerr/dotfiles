# load per-topic env files
for env_file ($PWD/.zshenvd/**/*(.N)); do
  source "$env_file"
done
unset env_file
