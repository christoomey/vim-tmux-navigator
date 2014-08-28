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

function! s:TmuxPaneCurrentCommand()
  echo system("tmux display-message -p '#{pane_current_command}'")
endfunction
command! TmuxPaneCurrentCommand call <SID>TmuxPaneCurrentCommand()

let s:tmux_is_last_pane = 0
au WinEnter * let s:tmux_is_last_pane = 0

" Like `wincmd` but also change tmux panes instead of vim windows when needed.
function! s:TmuxWinCmd(direction, ...)
  let rep = 0
  let reps = 1
  if a:0 > 0 && a:1 >0
    let reps = a:1
  endif

  while rep < reps
    if s:InTmuxSession()
      call s:TmuxAwareNavigate(a:direction)
    else
      call s:VimNavigate(a:direction)
    endif
    let rep += 1
  endwhile
endfunction

function! s:TmuxAwareNavigate(direction)
  let nr = winnr()
  let tmux_last_pane = (a:direction == 'p' && s:tmux_is_last_pane)
  if !tmux_last_pane
    call s:VimNavigate(a:direction)
  endif
  " Forward the switch panes command to tmux if:
  " a) we're toggling between the last tmux pane;
  " b) we tried switching windows in vim but it didn't have effect.
  if tmux_last_pane || nr == winnr()
    let cmd = 'tmux select-pane -' . tr(a:direction, 'phjkl', 'lLDUR')
    silent call system(cmd)
    if exists('g:loaded_vitality')
      redraw!
    endif
    let s:tmux_is_last_pane = 1
  else
    let s:tmux_is_last_pane = 0
  endif
endfunction

function! s:VimNavigate(direction)
  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

command! -nargs=1 TmuxNavigateLeft call <SID>TmuxWinCmd('h', <args>)
command! -nargs=1 TmuxNavigateDown call <SID>TmuxWinCmd('j', <args>)
command! -nargs=1 TmuxNavigateUp call <SID>TmuxWinCmd('k', <args>)
command! -nargs=1 TmuxNavigateRight call <SID>TmuxWinCmd('l', <args>)
command! TmuxNavigatePrevious call <SID>TmuxWinCmd('p')

if s:UseTmuxNavigatorMappings()
  nnoremap <silent> <c-h> :<c-u>TmuxNavigateLeft(v:count)<cr>
  nnoremap <silent> <c-j> :<c-u>TmuxNavigateDown(v:count)<cr>
  nnoremap <silent> <c-k> :<c-u>TmuxNavigateUp(v:count)<cr>
  nnoremap <silent> <c-l> :<c-u>TmuxNavigateRight(v:count)<cr>
  nnoremap <silent> <c-\> :TmuxNavigatePrevious<cr>
endif
