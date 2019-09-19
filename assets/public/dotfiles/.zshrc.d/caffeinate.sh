command -v systemd-inhibit > /dev/null
if (( $? == 0 )); then
  alias caffeinate=systemd-inhibit
fi
