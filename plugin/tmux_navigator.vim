" Maps <C-h/j/k/l> to switch vim splits in the given direction. If there are
" no more windows in that direction, forwards the operation to tmux.
" Additionally, <C-\> toggles between last active vim splits/tmux panes.

if exists("g:loaded_tmux_navigator") || &cp || v:version < 700
  finish
endif
let g:loaded_tmux_navigator = 1

function! s:UseTmuxNavigatorMappings()
  return !exists("g:tmux_navigator_no_mappings") || !g:tmux_navigator_no_mappings
endfunction

function! s:InTmuxSession()
  return $TMUX != ''
endfunction

let s:tmux_is_last_pane = 0
au WinEnter * let s:tmux_is_last_pane = 0

" Like `wincmd` but also change tmux panes instead of vim windows when needed.
function! s:TmuxWinCmd(direction)
  if s:InTmuxSession()
    call s:TmuxAwareNavigate(a:direction)
  else
    call s:VimNavigate(a:direction)
  endif
endfunction

function! s:TmuxAwareNavigate(direction)
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

function! s:VimNavigate(direction)
  execute 'wincmd ' . a:direction
endfunction

command! TmuxNavigateLeft call <SID>TmuxWinCmd('h')
command! TmuxNavigateDown call <SID>TmuxWinCmd('j')
command! TmuxNavigateUp call <SID>TmuxWinCmd('k')
command! TmuxNavigateRight call <SID>TmuxWinCmd('l')
command! TmuxNavigatePrevious call <SID>TmuxWinCmd('p')

if s:UseTmuxNavigatorMappings()
  nmap <silent> <c-h> :TmuxNavigateLeft<cr>
  nmap <silent> <c-j> :TmuxNavigateDown<cr>
  nmap <silent> <c-k> :TmuxNavigateUp<cr>
  nmap <silent> <c-l> :TmuxNavigateRight<cr>
  nmap <silent> <c-\> :TmuxNavigatePrevious<cr>
endif
