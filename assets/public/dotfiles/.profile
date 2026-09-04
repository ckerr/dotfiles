# load per-topic env files
#
# Ubuntu's Xsession sources ~/.profile with /bin/sh at graphical login, so
# this file and everything in ~/.profile.d must be POSIX shell -- no
# arrays, no [[ ]], no `declare`.

for file in "${HOME}"/.profile.d/*sh; do
  if [ -r "${file}" ]; then
    . "${file}"
  fi
done

unset file
