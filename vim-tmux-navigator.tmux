#!/usr/bin/env bash

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
tmux bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
tmux bind-key -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
tmux bind-key -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

# To enable clear screen using <Prefix><Ctrl+l>, uncomment the following line:
# bind C-l send-keys 'C-l'

# To send the clear screen command without requiring <Prefix> in tmux windows
# with only a single pane, replace the "tmux bind-key -n C-l" above with the
# following command:
# tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l" \
#     "if-shell \"[ '#{window_panes}' -gt 1 ]\" 'select-pane -R' 'send-keys C-l'"
