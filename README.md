# Dotfiles

## Installation:
```
git clone git://github.com/branderson/dotfiles.git
cd ~/dotfiles
./install.sh
```

## About:
OS: Arch Linux

WM: i3-gaps

Editor: vim

Shell: zsh/tmux

Terminal: urxvt

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
Alt-d:              Open Rofi launcher
Alt-Shift-w:        Open Rofi to switch workspace
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
Alt-Shift-q:        Close application
Alt-Shift-c:        Reload configuration
Alt-Shift-r:        Restart i3
Alt-Shift-e:        Exit i3
Alt-g:              Enable/Disable gaps
Alt-Shift-g:        Resize gaps
Alt-Escape:         Lock screen
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
K:                  Open man page (from command mode)
commands:           Open list of useful commands
sc:                 Open list of aliases
pyinit:             Initialize new python repository
xo:                 Alias to xdg-open
crontab-e:          Make changes to crontab (use instead of crontab -e)
```

### Other
```
Alt-Ctrl-Bksp:      Kill X-Server
```
