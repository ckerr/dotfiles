function ytdl-stream () {
  ytdl --no-cache --filter audioonly "$1" | cvlc --quiet -
}

function lofisleep() {
  ytdl-stream 'https://www.youtube.com/watch?v=DWcJFNfaw9c'
}

function lofi() {
  local -r LOFI_PATH="$HOME/Music/chilledcow"
  local -r WALLPAPER="$LOFI_PATH/video/[Wallpaper Engine]ChilledCow - Day - Nayoh Collections.mp4"
  local -r PLAYLIST="$LOFI_PATH/music/"
  mpv --no-audio --loop-file=inf --no-audio --fs --fs-screen=1 --really-quiet "$WALLPAPER" &
  mpv --no-video --loop-playlist=inf --shuffle "$PLAYLIST"
}
