#!/bin/sh

if [ "$1" == 'up' ]; then
  /usr/local/bin/hs -r -c 'hs.window.focusedWindow():focusWindowNorth()'
elif [ "$1" == 'down' ]; then
  /usr/local/bin/hs -r -c 'hs.window.focusedWindow():focusWindowSouth()'
elif [ "$1" == 'left' ]; then
  /usr/local/bin/hs -r -c 'hs.window.focusedWindow():focusWindowWest()'
elif [ "$1" == 'right' ]; then
  /usr/local/bin/hs -r -c 'hs.window.focusedWindow():focusWindowEast()'
fi
