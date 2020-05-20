function ytdl-stream () {
  ytdl --no-cache --filter audioonly "$1" | cvlc --quiet -
}

function lofisleep() {
  ytdl-stream 'https://www.youtube.com/watch?v=DWcJFNfaw9c'
}

function lofi() {
  local -r LOFI_PATH="$HOME/Music/chilledcow"
  mpv --loop --no-audio --really-quiet --fs --fs-screen=1 "$LOFI_PATH/video/[Wallpaper Engine]ChilledCow - Day - Nayoh Collections.mp4" &
  mpv --loop --no-video --shuffle "$LOFI_PATH/music"
}
