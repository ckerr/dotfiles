#!/usr/bin/env bash

set -uo pipefail

# These are applications, not libraries, so install them into their own
# venvs with pipx. A plain `pip install` fails on any PEP 668 system
# (Ubuntu 23.04 and newer) with `externally-managed-environment`.
declare -r PIPX_PACKAGES=(
  yt-dlp # successor to the abandoned youtube-dl / youtube-dlc
)

if ! command -v pipx > /dev/null 2>&1; then
  echo 'error: pipx not found; install it first (apt install pipx)' >&2
  exit 1
fi

for item in "${PIPX_PACKAGES[@]}"; do
  pipx install "${item}" || pipx upgrade "${item}"
done

echo "$0 done"
