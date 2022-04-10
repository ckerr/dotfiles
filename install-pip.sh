#!/usr/bin/env bash

declare -r PIP_PACKAGES=(
  youtube-dlc
  tartube
)

python3 -m pip install --upgrade ${PIP_PACKAGES[*]}
