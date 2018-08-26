# rust's cargo
cargo_bin="${CARGO_HOME:-${HOME}/.cargo}/bin"
if [[ ":$PATH:" != *":${cargo_bin}:"* ]]; then
  export PATH="${PATH}:${cargo_bin}"
fi
unset cargo_bin
