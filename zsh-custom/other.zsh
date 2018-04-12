# history
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=${HISTSIZE}
setopt hist_ignore_space

# rust's cargo
cargo_home="${CARGO_HOME:-${HOME}/.cargo}"
export PATH="${cargo_home}/bin:${PATH}"
