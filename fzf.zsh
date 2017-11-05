# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="$PATH:/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
if [ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]; then
    source "/usr/local/opt/fzf/shell/key-bindings.zsh"
fi

