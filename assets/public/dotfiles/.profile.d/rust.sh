# rust's cargo
cargo_bin="${CARGO_HOME:-${HOME}/.cargo}/bin"
case ":${PATH}:" in
  *":${cargo_bin}:"*)
    ;;
  *)
    PATH="${PATH}:${cargo_bin}"
    export PATH
    ;;
esac
unset cargo_bin
