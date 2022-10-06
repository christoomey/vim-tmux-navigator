#!/usr/bin/env bash

# pseudo substring match by substituting the current command from the current commmand string
tmux bind-key -n C-k if-shell "[ '#{pane_current_command}' != '#{s/g?(view|n?vim?x?)(diff)?$//:#{pane_current_command}}' ]" "send-keys C-k" "select-pane -U"
tmux bind-key -n C-j if-shell "[ '#{pane_current_command}' != '#{s/g?(view|n?vim?x?)(diff)?$//:#{pane_current_command}}' ]" "send-keys C-j" "select-pane -D"
tmux bind-key -n C-h if-shell "[ '#{pane_current_command}' != '#{s/g?(view|n?vim?x?)(diff)?$//:#{pane_current_command}}' ]" "send-keys C-h" "select-pane -L"
tmux bind-key -n C-l if-shell "[ '#{pane_current_command}' != '#{s/g?(view|n?vim?x?)(diff)?$//:#{pane_current_command}}' ]" "send-keys C-l" "select-pane -R"
# bring back clear screen (PREFIX + CTRL + l)
tmux bind-key C-l send-keys "C-l"

# if "${tmux_version}" is greater or equal "3.0", then "send-keys C-\\\\", else "send-keys C-\\"
# https://unix.stackexchange.com/a/285928
tmux_version=$(tmux display-message -p "#{version}")
tmux setenv -g tmux_version "${tmux_version}"

tmux if-shell -b "[ #(printf '%s\n' '3.0' '${tmux_version}' | sort --version-sort | head --lines='1') ]" \
    "bind-key -n C-\\ 'send-keys C-\\\\' 'select-pane -l'" \
    "bind-key -n C-\\ 'send-keys C-\\'  'select-pane -l'"

tmux bind-key -T copy-mode-vi C-h select-pane -L
tmux bind-key -T copy-mode-vi C-j select-pane -D
tmux bind-key -T copy-mode-vi C-k select-pane -U
tmux bind-key -T copy-mode-vi C-l select-pane -R
tmux bind-key -T copy-mode-vi C-\\ select-pane -l
