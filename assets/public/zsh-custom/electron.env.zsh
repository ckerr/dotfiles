export PATH="${PATH}:${HOME}/src/depot_tools"

# used by depot tools
export GIT_CACHE_PATH="${HOME}/.git_cache"
if [ ! -d "${GIT_CACHE_PATH}" ]; then
  mkdir "${GIT_CACHE_PATH}"
fi

# used by electron's sccache to share cache data with CI
export SCCACHE_BUCKET="electronjs-sccache"
export SCCACHE_TWO_TIER=true
