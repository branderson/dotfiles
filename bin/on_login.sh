#!/bin/zsh
[ -f "$HOME/.zsh_profile" ] && source "$HOME/.zsh_profile"
launchctl setenv PATH "$PATH"
killall Dock
killall Finder

# Kill Android Studio if open
ANDROID_STUDIO_PID=$(ps -A | grep "[A]ndroid Studio" -m1 | awk '{print $1}')
while kill -9 $ANDROID_STUDIO_PID 2> /dev/null; do
  sleep 1
done

# Reopen Android Studio if we killed it
if [ -n $ANDROID_STUDIO_PID ]; then
  open "/Applications/Android Studio.app"
fi

