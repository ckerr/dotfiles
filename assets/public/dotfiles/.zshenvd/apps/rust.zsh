# rust's cargo
cargo_home="${CARGO_HOME:-${HOME}/.cargo}"
if [[ ":$PATH:" != *"$cargo_home"* ]]; then
  export PATH="${cargo_home}/bin:${PATH}"
fi
