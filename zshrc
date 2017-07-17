# Gruvbox colors
# source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"
source "$HOME/dotfiles/gruvbox/gruvbox_256palette.sh"
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export RUST_SRC_PATH=/usr/local/src/rust/src

# Z
# . $HOME/dotfiles/z/z.sh
# Set name of the theme to load.
# # Look in ~/.oh-my-zsh/themes/
# # Optionally, if you set this to "random", it'll load a random theme each
# # time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"
# Base16 Shell
# BASE16_SHELL="$HOME/.config/base16-shell/base16-tomorrow.dark.sh"
# [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
# BASE16_SHELL="$HOME/.config/base16-shell/base16-ocean.dark.sh"
# [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
#
# # Uncomment the following line to use case-sensitive completion.
# # CASE_SENSITIVE="true"
#
# # Uncomment the following line to disable bi-weekly auto-update checks.
# # DISABLE_AUTO_UPDATE="true"
#
# # Uncomment the following line to change how often to auto-update (in days).
# # export UPDATE_ZSH_DAYS=13
#
# # Uncomment the following line to disable colors in ls.
# # DISABLE_LS_COLORS="true"
#
# # Uncomment the following line to disable auto-setting terminal title.
# # DISABLE_AUTO_TITLE="true"
#
# # Uncomment the following line to enable command auto-correction.
# # ENABLE_CORRECTION="true"
#
# # Uncomment the following line to display red dots whilst waiting for completion.
# # COMPLETION_WAITING_DOTS="true"
#
# # Uncomment the following line if you want to disable marking untracked files
# # under VCS as dirty. This makes repository status check for large repositories
# # much, much faster.
# # DISABLE_UNTRACKED_FILES_DIRTY="true"
#
# # Uncomment the following line if you want to change the command execution time
# # stamp shown in the history command output.
# # The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# # HIST_STAMPS="mm/dd/yyyy"
#
# # Would you like to use another custom folder than $ZSH/custom?
# # ZSH_CUSTOM=/path/to/new-custom-folder

# # zsh-syntax-highlighting must come last
plugins=(colorize command-not-found cp h git github gitflow tmux gibo bower grunt npm osx zsh-syntax-highlighting)

# # User configuration

#PATHs
export PATH=$HOME/bin:/usr/local/bin:$PATH
export MANPATH="/usr/local/man:$MANPATH"
PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
# Add user cowpath to COWPATH
COWPATH="$COWPATH:$HOME/dotfiles/cowfiles"
# Make a random (cow?) with a random face say something
# fortune -a | fmt -80 -s | cowthink -$(shuf -n 1 -e b d g p s t w y)  -f $(shuf -n 1 -e $(cowsay -l | tail -n +2)) -n

# User profiles
source ~/.profile
# Define $POWERLINE_ROOT
source ~/.profile.local

source $ZSH/oh-my-zsh.sh

# # Preferred editor for local and remote sessions
# # if [[ -n $SSH_CONNECTION ]]; then
export EDITOR='vim'
export TERM=xterm-256color

# # else
# #   export EDITOR='mvim'
# # fi
#
# # Compilation flags
# # export ARCHFLAGS="-arch x86_64"
#
# # ssh
# # export SSH_KEY_PATH="~/.ssh/dsa_id"
#
# # Set personal aliases, overriding those provided by oh-my-zsh libs,
# # plugins, and themes. Aliases can be placed here, though oh-my-zsh
# # users are encouraged to define aliases within the ZSH_CUSTOM folder.
# # For a full list of active aliases, run `alias`.
# #
# # Example aliases
# # alias zshconfig="mate ~/.zshrc"
# # alias ohmyzsh="mate ~/.oh-my-zsh"
alias -s txt=vim
alias -s .c=vim
# Crontab
alias crontab-e='vim ~/.crontab && crontab ~/.crontab'

# Lines configured by zsh-newuser-install
setopt appendhistory autocd extendedglob
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

DEFAULT_USER=brad

# Syntax highlighting configuration
# ZSH_HIGHLIGHT_STYLES[path]='bold'
# ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# ZSH_HIGHLIGHT_STYLES[path_approx]='fg=yellow'
# ZSH_HIGHLIGHT_STYLES[globbing]='fg=yellow'

# Source files
typeset -ga sources
sources+=~/dotfiles/shortcuts.txt

# Powerline plugin from distribution agnostic install directory
if [[ -a $POWERLINE_ROOT/bindings/zsh/powerline.zsh ]]; then
    # Prefer user-set powerline directory
    sources+=$POWERLINE_ROOT/bindings/zsh/powerline.zsh
else
    echo "Attempting to source Powerline bindings from default locations.\nPlease set \$POWERLINE_ROOT in .zshrc.local"
    # If $POWERLINE_ROOT not set or set incorrectly, try default locations
    sources+=/usr/lib/python2.6/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/lib/python2.6/dist-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/local/lib/python2.6/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/local/lib/python2.6/dist-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/lib/python2.7/dist-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/local/lib/python2.7/dist-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/lib/python3.6/dist-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/local/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=/usr/local/lib/python3.6/dist-packages/powerline/bindings/zsh/powerline.zsh
fi
foreach file (`echo $sources`)
    if [[ -a $file ]]; then
        source $file
    fi
end

# TMuxinator Completion
# source ~/bin/tmuxinator.zsh

# Dircolors
# eval $(dircolors ~/.dircolors)

# Keybindings
bindkey -M vicmd 'K' run-help
# bindkey -M viins 'K' run-help

# Make shell cd to ranger directory
ranger-cd() {
    tempfile=$(mktemp)
    ranger --choosedir="$tempfile" "${@:-$(pwd)}" < $TTY
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd $(cat $tempfile)
    fi
    zle reset-prompt
    printf '\n'
    rm -f -- "$tempfile"
}

terminal-clock() {
    tty-clock -tcb < $TTY
    zle reset-prompt
    printf '\n'
}

# This binds Ctrl-O to ranger-cd:
zle -N ranger-cd
bindkey '^o' ranger-cd
zle -N terminal-clock
bindkey '^t' terminal-clock

alias sl="sl -laF"

# Local overrides
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi

# source "/etc/profile.d/yelpcustom.zsh"

if [ "$TMUX" = "" ]; then tmux; fi
