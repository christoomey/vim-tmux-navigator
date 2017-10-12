#!/usr/bin/env bash

if [ -z "$VIM_TMUX_NAV_PAT" ]
then
    VIM_TMUX_NAV_PAT="(\\S+\\/)?g?(view|n?vim?x?)(diff)?"
fi

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +${VIM_TMUX_NAV_PAT}$'"
tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
tmux bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
tmux bind-key -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
tmux bind-key -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
tmux bind-key -T copy-mode-vi C-h select-pane -L
tmux bind-key -T copy-mode-vi C-j select-pane -D
tmux bind-key -T copy-mode-vi C-k select-pane -U
tmux bind-key -T copy-mode-vi C-l select-pane -R
tmux bind-key -T copy-mode-vi C-\\ select-pane -l
