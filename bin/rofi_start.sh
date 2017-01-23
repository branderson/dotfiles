#!/bin/env bash
res=`xrandr | head -n 1 | sed -r 's/.*current\s([0-9]+)\sx\s([0-9]+).*/\1x\2/g'`
screen_width=`echo $res | cut -d 'x' -f 1`
# screen_height=`echo $res | cut -d 'x' -f 2`
width=30
# pad=$((height / 5))
pad=$((width*screen_width/600))
opacity=100
i3-dmenu-desktop --dmenu="rofi -dmenu -p 'run: ' -opacity $opacity -width $width -padding $pad -color-enabled $(i3-color-rofi)"
