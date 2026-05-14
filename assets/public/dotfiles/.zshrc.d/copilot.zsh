# invoke this when cloning the repo into a new directory, eg:
# $ git clone git@github.com:transmission/transmission.git
# $ cd transmission
# $ copilot-link transmission
copilot-link() {
  local base="${XDG_CONFIG_HOME:-$HOME/.config}/copilot/model-memories/instructions"
  local rule_file="$base/$1.md"
  if [[ ! -f "$rule_file" ]]; then
    echo "No rule file: $rule_file"
    return 1
  fi
  mkdir -p .vscode
  ln -sf "$rule_file" .vscode/personal.instructions.md
  echo "Linked $1 → .vscode/personal.instructions.md"
}
