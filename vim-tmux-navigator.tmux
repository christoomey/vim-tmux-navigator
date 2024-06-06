#!/usr/bin/env bash

version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -ZL"
tmux bind-key -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -ZD"
tmux bind-key -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -ZU"
tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -ZR"
tmux_version="$(tmux -V | sed -En "$version_pat")"
tmux setenv -g tmux_version "$tmux_version"

#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json

tmux if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -Zl'"
tmux if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -Zl'"

tmux bind-key -T copy-mode-vi C-h select-pane -ZL
tmux bind-key -T copy-mode-vi C-j select-pane -ZD
tmux bind-key -T copy-mode-vi C-k select-pane -ZU
tmux bind-key -T copy-mode-vi C-l select-pane -ZR
tmux bind-key -T copy-mode-vi C-\\ select-pane -Zl
