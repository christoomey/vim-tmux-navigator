#!/usr/bin/env bash

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value=$(tmux show-option -gqv "$option")

  if [ -n "$value" ]; then
    if [ "$value" = "null" ]; then
      echo ""
    else
      echo "$value"
    fi
  else
    echo "$default"
  fi
}


version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'
move_left="$(get_tmux_option "@vim_navigator_mapping_left" "C-h")"
move_right="$(get_tmux_option "@vim_navigator_mapping_right" "C-l")"
move_up="$(get_tmux_option "@vim_navigator_mapping_up" "C-k")"
move_down="$(get_tmux_option "@vim_navigator_mapping_down" "C-j")"

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
tmux bind-key -n "$move_left"  if-shell "$is_vim" "send-keys $move_left"  "select-pane -L"
tmux bind-key -n "$move_down"  if-shell "$is_vim" "send-keys $move_down"  "select-pane -D"
tmux bind-key -n "$move_up"    if-shell "$is_vim" "send-keys $move_up"    "select-pane -U"
tmux bind-key -n "$move_right" if-shell "$is_vim" "send-keys $move_right" "select-pane -R"
tmux_version="$(tmux -V | sed -En "$version_pat")"
tmux setenv -g tmux_version "$tmux_version"

#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json

tmux if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
tmux if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

tmux bind-key -T copy-mode-vi "$move_left" select-pane -L
tmux bind-key -T copy-mode-vi "$move_down" select-pane -D
tmux bind-key -T copy-mode-vi "$move_up" select-pane -U
tmux bind-key -T copy-mode-vi "$move_right" select-pane -R
tmux bind-key -T copy-mode-vi C-\\ select-pane -l

