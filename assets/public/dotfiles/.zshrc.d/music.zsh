function ytdl-stream () {
  ytdl --no-cache --filter audioonly "$1" | cvlc --quiet -
}

function lofisleep() {
  ytdl-stream 'https://www.youtube.com/watch?v=DWcJFNfaw9c'
}

function lofi() {
  local -r focus_window="$(xdotool getactivewindow)"

  # pick one of the wallpapers and start it playing...
  local -r LOFI_PATH="$HOME/Music/chilledcow"
  local -r WALLPAPER="$(ls -1 $LOFI_PATH/video/* | shuf --head-count=1)"
  mpv --no-audio --loop-file=inf --fs --fs-screen=1 --really-quiet "$WALLPAPER" &
  local -r video_pid=$!

  # wait for the wallpaper to appear & grab its window id
  local video_window
  while [ -z "${video_window}" ]
  do
    sleep 0.1s
    video_window="$(xdotool search --pid ${video_pid})"
  done

  # make wallpaper always visible on any workspace
  wmctrl -i -r ${video_window} -b add,sticky

  # restore focus back from the walllpaper to this terminal
  xdotool windowfocus "${focus_window}"
  xdotool windowactivate "${focus_window}"

  # play some music
  local -r PLAYLIST="$LOFI_PATH/music/"
  mpv --no-video --loop-playlist=inf --shuffle "$PLAYLIST"

  # afer the music player exits, kill the video
  kill "${video_pid}"
}
