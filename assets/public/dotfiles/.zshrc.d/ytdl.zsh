function ytdl-stream () {
  ytdl --no-cache --filter audioonly "$1" | cvlc --quiet -
}

function lofi() {
  ytdl-stream 'https://www.youtube.com/watch?v=5qap5aO4i9A'
}

function lofisleep() {
  ytdl-stream 'https://www.youtube.com/watch?v=DWcJFNfaw9c'
}

