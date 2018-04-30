export SHELL=/bin/zsh
eval "$(aactivator init)"
exec /bin/zsh -l

export PATH="$HOME/.cargo/bin:$PATH"
