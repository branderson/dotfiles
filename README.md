Dotfiles

## Installation:
```
git clone git://github.com/branderson/dotfiles.git
cd ~/dotfiles
./install.sh

# To install middle click functionality for urxvt:
cp bin/osc-xterm-clipboard /usr/lib/urxvt/perl/
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
# Open programs
Alt-Enter:          Open terminal as new session targeting main tmux
Alt-t:              Open terminal with new tmux session
Alt-i:              Open browser
Alt-o:              Open ranger terminal
Alt-d:              Open Rofi launcher
Alt-v:              Open volume mixer

# Workspaces
Alt-Shift-Minus:    Send to scratchpad
Alt-Ctrl-Minus:     Show from scratchpad
Alt-<number>:       Switch to <number> workspace
Alt-Shift-<number>: Move to <number> workspace
Alt-Tab:            Switch to most recent workspace
Alt-Shift-Tab:      Switch to next workspace

# Layout
Alt-Minus:          Split next horizontally
Alt-Bar/Backslash:  Split next vertically
Alt-Space:          Toggle focus between floating and tiling
Alt-Shift-Space:    Toggle window between floating and tiling
Alt-Ctrl-<dir>:     Move <dir>
Alt-s:              Change layout to stacking
Alt-w:              Change layout to tabbed
Alt-e:              Change layout to split
Alt-g:              Enable/Disable gaps
Alt-Shift-g:        Resize gaps
Alt-r:              Resize windows

# Focus
Alt-a:              Focus parent
Alt-c:              Focus child
Alt-<dir>:          Focus <dir>
Alt-f:              Window fullscreen toggle

# Other
Alt-Shift-q:        Close application
Alt-Shift-c:        Reload configuration
Alt-Shift-r:        Restart i3
Alt-Shift-e:        Exit i3
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
q:                  Display split numbers (follow with <num> to switch)
z:                  Toggle pane zoom
t:                  Toggle pane clock
s:                  Switch tmux session
a:                  Toggle synchronize keyboard input across panes
```

### zsh
```
Ctrl-o:             Open ranger and cd to exit directory
Ctrl-t:             Display pretty clock
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
