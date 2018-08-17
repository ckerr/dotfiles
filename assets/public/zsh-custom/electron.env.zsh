export PATH="${PATH}:${HOME}/src/depot_tools"

# used by depot tools
export GIT_CACHE_PATH="${HOME}/.git_cache"
if [ ! -d "${GIT_CACHE_PATH}" ]; then
  mkdir "${GIT_CACHE_PATH}"
fi
