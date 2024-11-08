#!/usr/bin/env bash

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  # NOTE: Older tmux versions (eg. 3.2a on Ubuntu 22.04) do not exit with an
  #       error code when an option is not defined. Therefore we need to first
  #       test if the option exists, and only then try to get its value or fall
  #       back to the default.
  value="$([[ -n $(tmux show-options -gq "$option") ]] \
      && tmux show-option -gqv "$option" \
      || echo "$default")"

  # Deprecated, for backward compatibility
  if [[ $value == 'null' ]]; then
      echo ""
      return
  fi

  echo "$value"
}

bind_key_vim() {
  local key tmux_cmd is_vim
  key="$1"
  tmux_cmd="$2"
  is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
      | grep -iqE '^ ?[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
  # sending C-/ according to https://github.com/tmux/tmux/issues/1827
  tmux bind-key -n "$key" if-shell "$is_vim" "send-keys '$key'" "$tmux_cmd"
  # tmux < 3.0 cannot parse "$tmux_cmd" as one argument, thus copying as multiple arguments
  tmux bind-key -T copy-mode-vi "$key" $tmux_cmd
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
clear_screen="$(get_tmux_option "@vim_navigator_prefix_mapping_clear_screen" 'C-l')"
for k in $(echo "$clear_screen"); do tmux bind "$k" send-keys 'C-l'; done

