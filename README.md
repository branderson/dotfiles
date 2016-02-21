# Dotfiles

## Installation:
```
git clone git://github.com/branderson/dotfiles.git
cd ~/dotfiles
./install.sh
```

## About:
OS: Arch Linux

WM: i3

Editor: vim

Shell: zsh/tmux

## Usage:
### Basics
```
Alt is for i3 commands
Ctrl is left for programs except for Ctrl-a
Ctrl-a is for tmux commands
Comma is for vim commands
```

### i3
```
Alt-Enter:          Open terminal
Alt-i:              Open browser
Alt-o:              Open ranger terminal
Alt-d:              Open Rifi launcher
Alt-v:              Toggle volume mixer display
Alt-Ctrl-v:         Relaunch volume mixer
Alt-Shift-Minus:    Send to scratchpad
Alt-Ctrl-Minus:     Show from scratchpad
Alt-<number>:       Switch to <number> workspace
Alt-Shift-<number>: Move to <number> workspace
Alt-<dir>:          Focus <dir>
Alt-Ctrl-<dir>:     Move <dir>
Alt-Tab:            Switch to most recent workspace
Alt-Shift-Tab:      Switch to next workspace
```

### tmux
All commands prefixed by Ctrl-a
```
Ctrl-a:             Send Ctrl-a through to application
r:                  Reload tmux config
|:                  Open new horizontal split
-:                  Open new vertical split
c:                  Open new window at current directory
C:                  Display calendar
T:                  Make current window index 1
h, j, k, l:         Vim style movement between panes
<num>:              Switch to <num> window
```

### zsh
```
Ctrl-o:             Open ranger and cd to exit directory
```
