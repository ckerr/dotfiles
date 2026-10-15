#!/usr/bin/env bash

set -uo pipefail

# install-files.sh copies the unit files into ~/.config/systemd/user; this
# enables the timers among them. A machine without systemd (macOS) has
# nothing to enable.
if ! command -v systemctl &> /dev/null; then
  echo "skipping: no systemctl"
  echo "$0 done"
  exit 0
fi

systemctl --user daemon-reload
for timer in assets/public/dotfiles/.config/systemd/user/*.timer; do
  systemctl --user enable --now "$(basename "${timer}")"
done

echo "$0 done"
