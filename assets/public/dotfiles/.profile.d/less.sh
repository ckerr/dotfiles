# -R : Like -r, but only ANSI "color" escape sequences are output in "raw" form. Unlike -r, the screen appearance is
# -F or --quit-if-one-screen : Causes less to automatically exit if the entire file can be displayed on the first screen.
# -X or --no-init : Disables sending the termcap initialization and deinitialization strings to the terminal.
export LESS="-RFX"
