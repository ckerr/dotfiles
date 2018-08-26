# pick up depot_tools

dir="${HOME}/src/depot_tools"
if [[ ":$PATH:" != *"$dir"* ]]; then
  export PATH="${PATH}:${dir}"
fi

# used by depot_tools/gclient
export GIT_CACHE_PATH="${HOME}/.electron-cache/git-cache"
mkdir -p "${GIT_CACHE_PATH}"

# used by sccache
export SCCACHE_DIR="${HOME}/.electron-cache/sccache"
mkdir -p "${SCCACHE_DIR}"

# used by electron's branch of sccache to share with CI
export SCCACHE_BUCKET="electronjs-sccache"
export SCCACHE_TWO_TIER=true
