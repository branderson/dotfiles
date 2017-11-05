# Gruvbox colors
# source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"
source "$HOME/.gruvbox/gruvbox_256palette.sh"

# Custom functions
source "$HOME/.zsh_functions"

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
plugins=(archlinux colorize command-not-found cp h git github gitflow tmux gibo bower grunt npm osx zsh-syntax-highlighting)

# # User configuration

# Enable environment variables as CD directories
setopt cdablevars
# Enable correction for mistyped commands
setopt correctall

#PATHs
export PATH=$HOME/bin:/usr/local/bin:$PATH
export MANPATH="/usr/local/man:$MANPATH"
PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
# Add user cowpath to COWPATH
COWPATH="$COWPATH:$HOME/dotfiles/cowfiles"
# Make a random (cow?) with a random face say something
# fortune -a | fmt -80 -s | cowthink -$(shuf -n 1 -e b d g p s t w y)  -f $(shuf -n 1 -e $(cowsay -l | tail -n +2)) -n

# User profiles
source $HOME/.profile
# Define $POWERLINE_ROOT
if [ -f $HOME/.profile.local ]; then
    source $HOME/.profile.local
fi

source $ZSH/oh-my-zsh.sh

# Italic support
if [ -f $HOME/.xterm-256color-italic.terminfo ]; then
    tic $HOME/.xterm-256color-italic.terminfo
fi
# tic $HOME/.tmux.terminfo

# Use neovim where available
if type nvim > /dev/null 2>&1; then
    alias vim='nvim'
fi

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
sources+=$HOME/dotfiles/shortcuts.txt

# Powerline plugin from distribution agnostic install directory
pip install --user powerline-status &>/dev/null
if [[ -a $POWERLINE_ROOT/bindings/zsh/powerline.zsh ]]; then
    # Prefer user-set powerline directory
    sources+=$POWERLINE_ROOT/bindings/zsh/powerline.zsh
else
    echo "Attempting to source Powerline bindings from default locations.\nPlease set \$POWERLINE_ROOT in .profile.local"
    # If $POWERLINE_ROOT not set or set incorrectly, try default locations
    sources+=$HOME/.local/lib/python2.6/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=$HOME/.local/lib/python2.6/dist-packages/powerline/bindings/zsh/powerline.zsh
    sources+=$HOME/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=$HOME/.local/lib/python2.7/dist-packages/powerline/bindings/zsh/powerline.zsh
    sources+=$HOME/.local/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh
    sources+=$HOME/.local/lib/python3.6/dist-packages/powerline/bindings/zsh/powerline.zsh
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

# Check dotfiles version
check_dotfiles_version
dotfiles_version=$?
if [[ $dotfiles_version = 1 ]]; then
    echo "Dotfiles repository not present at $HOME/dotfiles"
elif [[ $dotfiles_version = 2 ]]; then
    echo "Dotfiles repository at $HOME/dotfiles is outdated"
elif [[ $dotfiles_version = 3 ]]; then
    echo "Dotfiles repository at $HOME/dotfiles is ahead of origin"
elif [[ $dotfiles_version = 4 ]]; then
    echo "Dotfiles repository at $HOME/dotfiles has diverged from origin"
fi

# TMuxinator Completion
# source ~/bin/tmuxinator.zsh

# Dircolors
# eval $(dircolors ~/.dircolors)

# Keybindings
bindkey -M vicmd 'K' run-help
bindkey -M viins ',,' vi-cmd-mode
# bindkey -M viins 'K' run-help

# This binds Ctrl-O to ranger-cd:
zle -N ranger-cd
bindkey '^o' ranger-cd
zle -N terminal-clock
bindkey '^t' terminal-clock

alias sl="sl -laF"

# Tool options
export SHELLCHECK_OPTS="-e SC2029 -e SC2155"

# Local overrides
if [ -f $HOME/.zshrc_local ]; then
    source $HOME/.zshrc_local
fi
