" Maps <C-h/j/k/l> to switch vim splits in the given direction. If there are
" no more windows in that direction, forwards the operation to tmux.
" Additionally, <C-\> toggles between last active vim splits/tmux panes.

if $TMUX != ''
  let s:tmux_is_last_pane = 0
  au WinEnter * let s:tmux_is_last_pane = 0

  " Like `wincmd` but also change tmux panes instead of vim windows when needed.
  function! s:TmuxWinCmd(direction)
    let nr = winnr()
    let tmux_last_pane = (a:direction == 'p' && s:tmux_is_last_pane)
    if !tmux_last_pane
      " try to switch windows within vim
      exec 'wincmd ' . a:direction
    endif
    " Forward the switch panes command to tmux if:
    " a) we're toggling between the last tmux pane;
    " b) we tried switching windows in vim but it didn't have effect.
    if tmux_last_pane || nr == winnr()
      let cmd = 'tmux select-pane -' . tr(a:direction, 'phjkl', 'lLDUR')
      silent call system(cmd)
      let s:tmux_is_last_pane = 1
    else
      let s:tmux_is_last_pane = 0
    endif
  endfunction

  " navigate between split windows/tmux panes
  nmap <silent> <c-j> :call <SID>TmuxWinCmd('j')<cr>
  nmap <silent> <c-k> :call <SID>TmuxWinCmd('k')<cr>
  nmap <silent> <c-h> :call <SID>TmuxWinCmd('h')<cr>
  nmap <silent> <c-l> :call <SID>TmuxWinCmd('l')<cr>
  nmap <silent> <c-\> :call <SID>TmuxWinCmd('p')<cr>
else
  noremap <C-j> <C-w>j
  noremap <C-k> <C-w>k
  noremap <C-h> <C-w>h
  noremap <C-l> <C-w>l
  noremap <C-\> <C-w>p
end
