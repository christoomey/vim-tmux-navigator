#!/bin/sh

# Based on the blogpost by Daniel Campoverde
# http://silly-bytes.blogspot.com.br/2016/06/seamlessly-vim-tmux-windowmanager_24.html

CURRENT_DIR=$(dirname "$0")
SWITCHER="${OS_WINDOW_SWITCHER:-$CURRENT_DIR/hammerspoon_switcher.sh}"

silent() {
  $* > /dev/null
}

window_bottom=$(tmux list-panes -F "#{window_height}" | head -n1)
window_right=$(tmux list-panes -F "#{window_width}" | head -n1)
window_bottom=$(($window_bottom - 1))
window_right=$(($window_right - 1))
pane=$(tmux list-panes -F "#{pane_left} #{pane_right} #{pane_top} #{pane_bottom} #{pane_active}" | grep '.* 1$')
pane_left=$(echo "$pane" | cut -d' ' -f 1)
pane_right=$(echo "$pane" | cut -d' ' -f 2)
pane_top=$(echo "$pane" | cut -d' ' -f 3)
pane_bottom=$(echo "$pane" | cut -d' ' -f 4)

function os_tmux_up
{
  if [[ $pane_top  -eq 0 ]];
  then
    silent $SWITCHER up
  else
    tmux select-pane -U
  fi
}

function os_tmux_down
{
  if [[ $pane_bottom  -eq $window_bottom ]];
  then
    silent $SWITCHER down
  else
    tmux select-pane -D
  fi
}

function os_tmux_right
{
  if [[ $pane_right  -eq $window_right ]];
  then
    silent $SWITCHER right
  else
    tmux select-pane -R
  fi
}

function os_tmux_left
{
  if [[ $pane_left  -eq 0 ]];
  then
    silent $SWITCHER left
  else
    tmux select-pane -L
  fi
}

if [ "$1" == 'up' ]; then
  os_tmux_up
elif [ "$1" == 'down' ]; then
  os_tmux_down
elif [ "$1" == 'left' ]; then
  os_tmux_left
elif [ "$1" == 'right' ]; then
  os_tmux_right
fi
