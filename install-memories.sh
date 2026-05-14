#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:ckerr/model-memories.git"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/copilot/model-memories"
VSCODE_MEM="$HOME/.config/Code/User/globalStorage/github.copilot-chat/memory-tool/memories"

if [[ -d "$DEST" ]]; then
  echo "model-memories already present at $DEST, pulling latest"
  git -C "$DEST" pull --ff-only
else
  echo "Cloning model-memories to $DEST"
  git clone "$REPO_URL" "$DEST"
fi

if [[ -L "$VSCODE_MEM" ]]; then
  echo "VS Code memories symlink already in place"
elif [[ -d "$VSCODE_MEM" ]]; then
  echo "Replacing VS Code memories directory with symlink"
  rm -rf "$VSCODE_MEM"
  ln -s "$DEST/memories" "$VSCODE_MEM"
else
  mkdir -p "$(dirname "$VSCODE_MEM")"
  ln -s "$DEST/memories" "$VSCODE_MEM"
fi

echo "install-memories.sh done"
