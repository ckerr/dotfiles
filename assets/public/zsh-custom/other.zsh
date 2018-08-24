# history
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=${HISTSIZE}
setopt hist_ignore_space

# rust's cargo
cargo_home="${CARGO_HOME:-${HOME}/.cargo}"
export PATH="${cargo_home}/bin:${PATH}"

# shortcuts
function figar0 {
  find ./ -type f -print0 | xargs -0 grep --color=always $1 | less -R
}

# disable single-quoting of files in ls
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=877582
export QUOTING_STYLE=literal
