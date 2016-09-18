function allow_nested() {
  tmux show-options -g @navigation-nested &> /dev/null || return 1
}

function is_nested() {
  allow_nested && $CURRENT_DIR/is-running "ssh|tmux"
}
