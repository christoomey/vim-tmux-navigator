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

bind_key_vim() {
  local key tmux_cmd is_vim
  key="$1"
  tmux_cmd="$2"
  is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
      | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
  tmux bind-key -n "$key" if-shell "$is_vim" "send-keys $key" "$tmux_cmd"
  tmux bind-key -T copy-mode-vi "$key" "$tmux_cmd"
}

version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'
move_left="$(get_tmux_option "@vim_navigator_mapping_left" "C-h")"
move_right="$(get_tmux_option "@vim_navigator_mapping_right" "C-l")"
move_up="$(get_tmux_option "@vim_navigator_mapping_up" "C-k")"
move_down="$(get_tmux_option "@vim_navigator_mapping_down" "C-j")"

for k in $(echo "$move_left");  do bind_key_vim "$k" "select-pane -L"; done
for k in $(echo "$move_down");  do bind_key_vim "$k" "select-pane -D"; done
for k in $(echo "$move_up");    do bind_key_vim "$k" "select-pane -U"; done
for k in $(echo "$move_right"); do bind_key_vim "$k" "select-pane -R"; done

tmux_version="$(tmux -V | sed -En "$version_pat")"
tmux setenv -g tmux_version "$tmux_version"

#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json

#is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
#    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
#tmux if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
#  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
#tmux if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
#  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"
#tmux bind-key -T copy-mode-vi C-\\ select-pane -l

