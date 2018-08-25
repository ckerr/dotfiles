# load per-topic rc files
for rc_file ($PWD/.zshrcd/**/*(.N)); do
  source "$rc_file"
done
unset rc_file
