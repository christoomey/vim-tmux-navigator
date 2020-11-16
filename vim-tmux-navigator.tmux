#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

source "$SCRIPTS_DIR/tmux_cmd_path.sh"

version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'

# Try to find the executable path of the currently running 
# tmux server, fallback to just "tmux" if not found or no 
# procfs aviliable (non-linux).
export TMUX_CMD_PATH=$(realpath "/proc/$(tmux display -p '#{pid}')/exe" 2> /dev/null || echo "tmux" | sed -z '$ s/\n$//')
echo "tmux executable used: $TMUX_CMD_PATH"

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
$TMUX_CMD_PATH bind-key -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
$TMUX_CMD_PATH bind-key -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
$TMUX_CMD_PATH bind-key -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
$TMUX_CMD_PATH bind-key -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
tmux_version="$($TMUX_CMD_PATH -V | sed -En "$version_pat")"
$TMUX_CMD_PATH setenv -g tmux_version "$tmux_version"

#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json

$TMUX_CMD_PATH if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
$TMUX_CMD_PATH if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

$TMUX_CMD_PATH bind-key -T copy-mode-vi C-h select-pane -L
$TMUX_CMD_PATH bind-key -T copy-mode-vi C-j select-pane -D
$TMUX_CMD_PATH bind-key -T copy-mode-vi C-k select-pane -U
$TMUX_CMD_PATH bind-key -T copy-mode-vi C-l select-pane -R
$TMUX_CMD_PATH bind-key -T copy-mode-vi C-\\ select-pane -l
