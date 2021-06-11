#!/bin/sh

userresources=$HOME/.Xresources
userurxvtresources=$HOME/.urxvt.xresources
gruvboxresources=$HOME/dotfiles/gruvbox-contrib/xresources/gruvbox-dark.xresources
gruvboxurxvtresources=$HOME/dotfiles/gruvbox-contrib/urxvt256/gruvbox-urxvt256.xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$userurxvtresources" ]; then
    xrdb -merge "$userurxvtresources"
fi

if [ -f "$gruvboxresources" ]; then
    xrdb -merge "$gruvboxresources"
fi

if [ -f "$gruvboxurxvtresources" ]; then
    xrdb -merge "$gruvboxurxvtresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

#if [ -f "/etc/arch-release" ]; then
    # start some nice programs
#    /usr/bin/dropbox &
#fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# twm &
# xclock -geometry 50x50-1+1 &
# xterm -geometry 80x50+494+51 &
# xterm -geometry 80x20+494-0 &
# exec xterm -geometry 80x66+0+0 -name login

if [ -f "/etc/arch-release" ]; then
    # Set up X keyboard shortcuts
    setxkbmap -option terminate:ctrl_alt_bksp

    exec i3
else
    exec zsh
fi
