#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
echo $CURRENT_DIR
tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "run-shell \"\"$CURRENT_DIR/scripts/os_tmux_navigator.sh\" left\""
tmux bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "run-shell \"\"$CURRENT_DIR/scripts/os_tmux_navigator.sh\" down\""
tmux bind-key -n C-k if-shell "$is_vim" "send-keys C-k"  "run-shell \"\"$CURRENT_DIR/scripts/os_tmux_navigator.sh\" up\""
tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "run-shell \"\"$CURRENT_DIR/scripts/os_tmux_navigator.sh\" right\""
tmux bind-key -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
