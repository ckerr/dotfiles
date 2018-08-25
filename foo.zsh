(cd assets/public/dotfiles && find -name ".[^.]*" -type f -exec install -v -Dm 644 "{}" "/tmp/foo/{}" \;)
(cd assets/public/dotfiles && find -path ".[^.]*/**/*" -type f -exec install -v -Dm 644 "{}" "/tmp/foo/{}" \;)

