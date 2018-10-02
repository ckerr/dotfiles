setopt hist_ignore_space

who_the_fuck_is_using_port() { sudo lsof -iTCP:$1 }
