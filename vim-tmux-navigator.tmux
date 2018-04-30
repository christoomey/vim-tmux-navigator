#!/usr/bin/env bash

tmux bind-key -n C-h if-shell -F '#{m:*-#{pane_id}-*,#{@tmux_navigator}}' "send-keys C-h" "select-pane -L"
tmux bind-key -n C-j if-shell -F '#{m:*-#{pane_id}-*,#{@tmux_navigator}}' "send-keys C-j" "select-pane -D"
tmux bind-key -n C-k if-shell -F '#{m:*-#{pane_id}-*,#{@tmux_navigator}}' "send-keys C-k" "select-pane -U"
tmux bind-key -n C-l if-shell -F '#{m:*-#{pane_id}-*,#{@tmux_navigator}}' "send-keys C-l" "select-pane -R"
tmux bind-key -n C-\\ if-shell -F '#{m:*-#{pane_id}-*,#{@tmux_navigator}}' "send-keys C-\\" "select-pane -l"

tmux bind-key -T copy-mode-vi C-h select-pane -L
tmux bind-key -T copy-mode-vi C-j select-pane -D
tmux bind-key -T copy-mode-vi C-k select-pane -U
tmux bind-key -T copy-mode-vi C-l select-pane -R
tmux bind-key -T copy-mode-vi C-\\ select-pane -l
