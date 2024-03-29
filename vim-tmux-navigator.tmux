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
  # sending C-/ according to https://github.com/tmux/tmux/issues/1827
  tmux bind-key -n "$key" if-shell "$is_vim" "send-keys '$key'" "$tmux_cmd"
  tmux bind-key -T copy-mode-vi "$key" "$tmux_cmd"
}

move_left="$(get_tmux_option "@vim_navigator_mapping_left" 'C-h')"
move_right="$(get_tmux_option "@vim_navigator_mapping_right" 'C-l')"
move_up="$(get_tmux_option "@vim_navigator_mapping_up" 'C-k')"
move_down="$(get_tmux_option "@vim_navigator_mapping_down" 'C-j')"
move_prev="$(get_tmux_option "@vim_navigator_mapping_prev" 'C-\')"

for k in $(echo "$move_left");  do bind_key_vim "$k" "select-pane -L"; done
for k in $(echo "$move_down");  do bind_key_vim "$k" "select-pane -D"; done
for k in $(echo "$move_up");    do bind_key_vim "$k" "select-pane -U"; done
for k in $(echo "$move_right"); do bind_key_vim "$k" "select-pane -R"; done
for k in $(echo "$move_prev");  do bind_key_vim "$k" "select-pane -l"; done

# Restoring clear screen
tmux bind C-l send-keys 'C-l'

