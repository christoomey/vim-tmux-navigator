function window_height() {
  tmux display-message -p "#{window_height}"
}

function window_width() {
  tmux display-message -p "#{window_width}"
}

function pane_top() {
  tmux display-message -p "#{pane_top}"
}

function pane_bottom() {
  tmux display-message -p "#{pane_bottom}"
}

function pane_left() {
  tmux display-message -p "#{pane_left}"
}

function pane_right() {
  tmux display-message -p "#{pane_right}"
}

function pane_index() {
  tmux display-message -p "#{pane_index}"
}

function is_bounded() {
  tmux show-options -g @navigation-bounded &> /dev/null || return 1
}

function can_select_pane() {
  if is_bounded || is_nested; then
    case $1 in
      L)
        [[ $(pane_left) -gt 0 ]]
        ;;
      R)
        [[ $(pane_right) -lt $(($(window_width) - 1)) ]]
        ;;
      U)
        [[ $(pane_top) -gt 0 ]]
        ;;
      D)
        [[ $(pane_bottom) -lt $(($(window_height) - 1)) ]]
        ;;
    esac
  fi
}

function select_pane() {
  case $1 in
    L)
      is_nested && select_pane_left || tmux select-pane -L
      ;;
    R)
      is_nested && select_pane_right || tmux select-pane -R
      ;;
    U)
      is_nested && select_pane_up || tmux select-pane -U
      ;;
    D)
      is_nested && select_pane_down || tmux select-pane -D
      ;;
  esac
}

function select_pane_dir() {
  local bound dir index lower offset op pane pos selected upper
  op=$1
  dir=$2
  bound=$3
  lower=$4
  upper=$5
  offset=$6

  IFS=',' read pane dir pos offset <<< \
    $(tmux display-message -p "#{pane_index},#{pane_$dir},#{pane_$upper},#{cursor_$offset}")
  pos=$(($pos + $offset))

  panes=("$(tmux list-panes \
    -F "#{pane_index},#{pane_$upper},#{pane_$lower},#{pane_$bound}")")
  for p in ${panes[@]}; do
    IFS=',' read index upper lower bound <<< $p
    [[ $index -eq $pane ]] && continue

    if [[ $pos -ge $upper ]] && [[ $pos -le $lower ]]; then
      if [[ $(($dir $op 2)) -eq $bound ]]; then
        selected=$index
        break
      fi
    fi
  done

  if [ $selected ]; then
    tmux select-pane -t $selected
  fi
}

function select_pane_left() {
  select_pane_dir "-" "left" "right" "bottom" "top" "y"
}                                    
                                     
function select_pane_right() {       
  select_pane_dir "+" "right" "left" "bottom" "top" "y"
}                                    
                                     
function select_pane_up() {          
  select_pane_dir "-" "top" "bottom" "right" "left" "x"
}                                    
                                     
function select_pane_down() {        
  select_pane_dir "+" "bottom" "top" "right" "left" "x"
}
